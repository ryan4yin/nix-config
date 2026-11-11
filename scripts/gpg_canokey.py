#!/usr/bin/env python3
"""Switch pass to a new hardware-backed OpenPGP key: create it, switch the store, load the CanoKeys.

Steps, in order (docs/security-keys.md, "pass (OpenPGP)"):

    generate  create the key and write its age-encrypted backup to every --dest
    pass      re-encrypt the password store from the old key to the new one
    card      move the [S] and [E] subkeys onto the plugged-in CanoKey

Each step builds throwaway keyrings on tmpfs ($XDG_RUNTIME_DIR) and deletes them on exit. `pass` and
`card` restore the key from the backup, so a backup that does not restore stops them before the
store or a card changes.
"""

from __future__ import annotations

import argparse
import contextlib
import hashlib
import io
import os
import subprocess
import sys
import tarfile
import tempfile
import time
from collections.abc import Callable, Iterator
from dataclasses import dataclass
from pathlib import Path

GPG = "gpg"
AGE = "age"
AGE_ATTEMPTS = 3

SECRET_MEMBER = "secret.asc"
REVOCATION_MEMBER = "revocation.asc"

SIG_SLOT = 1
DEC_SLOT = 2


class Abort(Exception):
    """A check failed; the message says what is wrong."""


def say(message: str) -> None:
    print(f"==> {message}", flush=True)


class Prompts:
    """Lists a command's prompts up front, then announces each one and what follows it."""

    def __init__(self, *steps: str) -> None:
        self.steps = steps
        self.done = 0
        say(f"this asks for {len(steps)} things, in this order:")
        for number, step in enumerate(steps, 1):
            print(f"    {number}. {step}", flush=True)

    def next(self) -> None:
        self.done += 1
        then = self.steps[self.done] if self.done < len(self.steps) else "nothing more"
        say(f"[{self.done}/{len(self.steps)}] now: {self.steps[self.done - 1]}")
        print(f"    after that: {then}", flush=True)


def run(
    command: list[str],
    *,
    env: dict[str, str] | None = None,
    data: bytes | None = None,
    interactive: bool = False,
) -> bytes:
    """Return the command's stdout; `interactive` leaves stderr on the terminal for prompts."""
    result = subprocess.run(
        command,
        input=data,
        stdout=subprocess.PIPE,
        stderr=None if interactive else subprocess.PIPE,
        env=env,
        check=False,
    )
    if result.returncode != 0:
        lines = (result.stderr or b"").decode(errors="replace").strip().splitlines()
        reason = lines[-1] if lines else f"exit code {result.returncode}"
        raise Abort(f"`{' '.join(command[:2])}` failed: {reason}")
    return result.stdout


def age_prompting(*args: str, data: bytes) -> bytes:
    """Run age, asking again when a passphrase is mistyped, so a typo does not abort the command."""
    for attempt in range(1, AGE_ATTEMPTS + 1):
        try:
            return run([AGE, *args], data=data, interactive=True)
        except Abort:
            if attempt == AGE_ATTEMPTS:
                raise
            say(f"age failed (see above); try again, attempt {attempt + 1} of {AGE_ATTEMPTS}")
    raise AssertionError("unreachable")


def age_encrypt(data: bytes) -> bytes:
    """Encrypt with a passphrase that age asks for on the terminal."""
    return age_prompting("--passphrase", data=data)


def age_decrypt(data: bytes) -> bytes:
    return age_prompting("--decrypt", data=data)


# --------------------------------------------------------------------------- #
# keyrings
# --------------------------------------------------------------------------- #


@dataclass(frozen=True)
class Keyring:
    home: Path

    @property
    def env(self) -> dict[str, str]:
        return os.environ | {"GNUPGHOME": str(self.home), "LC_ALL": "C"}

    def gpg(self, *args: str, data: bytes | None = None) -> bytes:
        return run([GPG, *args], env=self.env, data=data)

    def text(self, *args: str) -> str:
        return self.gpg(*args).decode()


@contextlib.contextmanager
def scratch_keyring() -> Iterator[Keyring]:
    """An empty GNUPGHOME on tmpfs, deleted together with its agent on exit."""
    runtime = os.environ.get("XDG_RUNTIME_DIR", "")
    if not runtime:
        raise Abort("XDG_RUNTIME_DIR is unset; run this from a desktop session")
    fstype = run(["stat", "--file-system", "--format=%T", runtime]).decode().strip()
    if fstype != "tmpfs":
        raise Abort(f"{runtime} is {fstype}, not tmpfs")
    with tempfile.TemporaryDirectory(prefix="gpg-canokey-", dir=runtime) as home:
        # Reach the CanoKey through pcscd, as the daily keyring does.
        Path(home, "scdaemon.conf").write_text("disable-ccid\n")
        ring = Keyring(Path(home))
        try:
            yield ring
        finally:
            subprocess.run(
                ["gpgconf", "--kill", "all"], env=ring.env, capture_output=True, check=False
            )


@dataclass(frozen=True)
class Key:
    primary: str
    sign: str
    encrypt: str


@dataclass(frozen=True)
class SecretKey:
    usage: str
    fingerprint: str
    token: str  # the card's AID when the secret is on a card, "+" when it is on disk


def secret_keys(ring: Keyring) -> list[list[SecretKey]]:
    """Each secret key: the primary, then its subkeys in edit-key order."""
    keys: list[list[SecretKey]] = []
    usage = token = ""
    for line in ring.text("--list-secret-keys", "--with-colons").splitlines():
        fields = line.split(":")
        if fields[0] in ("sec", "ssb"):
            usage = "primary" if fields[0] == "sec" else fields[11]
            token = fields[14]
            if fields[0] == "sec":
                keys.append([])
        elif fields[0] == "fpr" and keys:
            keys[-1].append(SecretKey(usage, fields[9], token))
    return keys


def read_key(ring: Keyring) -> Key:
    """The keyring's only secret key; its subkeys are found by usage."""
    keys = secret_keys(ring)
    if len(keys) != 1:
        raise Abort(f"expected one secret key, found {len(keys)}")
    usages = {part.usage: part.fingerprint for part in keys[0]}
    if not {"primary", "s", "e"} <= usages.keys():
        raise Abort("the key lacks an [S] or an [E] subkey")
    return Key(primary=usages["primary"], sign=usages["s"], encrypt=usages["e"])


def import_secret(ring: Keyring, secret: bytes) -> Key:
    """Import the key and trust it ultimately, as the daily keyring trusts its own key."""
    ring.gpg("--batch", "--import", data=secret)
    key = read_key(ring)
    ring.gpg("--import-ownertrust", data=f"{key.primary}:6:\n".encode())
    return key


# --------------------------------------------------------------------------- #
# backup archive
# --------------------------------------------------------------------------- #


def pack(secret: bytes, revocation: bytes) -> bytes:
    buffer = io.BytesIO()
    with tarfile.open(fileobj=buffer, mode="w") as archive:
        for name, data in ((SECRET_MEMBER, secret), (REVOCATION_MEMBER, revocation)):
            info = tarfile.TarInfo(name)
            info.size = len(data)
            info.mode = 0o600
            info.mtime = int(time.time())
            archive.addfile(info, io.BytesIO(data))
    return buffer.getvalue()


def unpack(blob: bytes) -> tuple[bytes, bytes]:
    """(secret key, revocation certificate) from a decrypted backup."""
    try:
        with tarfile.open(fileobj=io.BytesIO(blob)) as archive:
            secret, revocation = (
                archive.extractfile(name).read()  # type: ignore[union-attr]
                for name in (SECRET_MEMBER, REVOCATION_MEMBER)
            )
    except (tarfile.TarError, KeyError, AttributeError):
        raise Abort("the backup is not an archive written by `generate`") from None
    return secret, revocation


def unprotected(ring: Keyring) -> list[str]:
    """Keygrips of secret keys stored without a passphrase."""
    listing = ring.text("--list-secret-keys", "--with-colons", "--with-keygrip")
    grips = [line.split(":")[9] for line in listing.splitlines() if line.startswith("grp:")]
    info = run(["gpg-connect-agent", *(f"KEYINFO {grip}" for grip in grips), "/bye"], env=ring.env)
    # S KEYINFO <keygrip> <type> <serial> <idstr> <cached> <protection: P, C or -> ...
    return [
        fields[2]
        for fields in (line.split() for line in info.decode().splitlines())
        if fields[:2] == ["S", "KEYINFO"] and fields[7] != "P"
    ]


def check_backup(blob: bytes, key: Key) -> None:
    """The archive restores `key` with a passphrase, and its revocation certificate revokes it."""
    secret, revocation = unpack(blob)
    with scratch_keyring() as ring:
        if import_secret(ring, secret) != key:
            raise Abort("the backup holds a different key")
        if unprotected(ring):
            raise Abort("the backup's secret key has no GPG passphrase")
        ring.gpg("--batch", "--import", data=revocation)
        listing = ring.text("--list-keys", "--with-colons", key.primary).splitlines()
        validity = next(line.split(":")[1] for line in listing if line.startswith("pub:"))
        if validity != "r":
            raise Abort("the backup's revocation certificate does not revoke the key")


def restore(ring: Keyring, backup: Path) -> Key:
    say(f"restoring the key from {backup}")
    secret, _ = unpack(age_decrypt(backup.read_bytes()))
    return import_secret(ring, secret)


# --------------------------------------------------------------------------- #
# generate
# --------------------------------------------------------------------------- #


def cmd_generate(args: argparse.Namespace) -> None:
    dests = [Path(dest).expanduser() for dest in args.dest]
    for dest in dests:
        if not dest.is_dir():
            raise Abort(f"{dest} is not a directory; is the drive mounted?")
    public_key = Path(args.public_key).expanduser()
    if public_key.exists():
        raise Abort(f"{public_key} already exists")

    prompts = Prompts(
        "a new GPG passphrase, in 3 pinentry dialogs (the [C], [S] and [E] keys); "
        "type the same one twice in each",
        "the GPG passphrase once more, in pinentry, to export the key",
        "the backup's age passphrase (the L0 passphrase), twice in this terminal",
        "the age passphrase once more, to check that the backup restores",
    )
    batch = ("--batch", "--pinentry-mode", "loopback", "--passphrase", "")
    with scratch_keyring() as ring:
        say("generating an ed25519 [C] key with ed25519 [S] and cv25519 [E] subkeys")
        ring.gpg(*batch, "--quick-generate-key", args.uid, "ed25519", "cert", "never")
        primary = secret_keys(ring)[0][0].fingerprint
        ring.gpg(*batch, "--quick-add-key", primary, "ed25519", "sign", "never")
        ring.gpg(*batch, "--quick-add-key", primary, "cv25519", "encr", "never")
        key = read_key(ring)
        # It keeps the key protected on tmpfs whenever the age backup is opened; age's scrypt
        # outside covers gpg's weaker S2K against offline guessing.
        prompts.next()
        ring.gpg("--batch", "--passwd", key.primary)
        prompts.next()
        secret = ring.gpg("--batch", "--armor", "--export-secret-keys", key.primary)
        public = ring.gpg("--armor", "--export", key.primary)
        stored = (ring.home / "openpgp-revocs.d" / f"{key.primary}.rev").read_bytes()
    # gpg puts a colon before the armor header so the certificate cannot be imported by accident.
    revocation = stored.replace(b":-----BEGIN", b"-----BEGIN", 1)

    prompts.next()
    sealed = age_encrypt(pack(secret, revocation))
    copies = [dest / f"gpg-{key.primary}.tar.age" for dest in dests]
    for copy in copies:
        copy.write_bytes(sealed)
    os.sync()
    if any(copy.read_bytes() != sealed for copy in copies):
        raise Abort("a backup copy reads back different bytes")
    prompts.next()
    check_backup(age_decrypt(copies[0].read_bytes()), key)
    public_key.write_bytes(public)

    say(f"primary  {key.primary}")
    say(f"sign     {key.sign}")
    say(f"encrypt  {key.encrypt}")
    for copy in copies:
        say(f"backup   {copy}")
    say(f"public   {public_key}")


# --------------------------------------------------------------------------- #
# pass
# --------------------------------------------------------------------------- #


def store_entries(store: Path) -> list[Path]:
    return sorted(
        path for path in store.rglob("*.gpg") if ".git" not in path.relative_to(store).parts
    )


def git(store: Path, *args: str) -> str:
    return run(["git", "-C", str(store), *args]).decode().strip()


def decrypt_digest(ring: Keyring, entry: Path) -> str:
    return hashlib.sha256(ring.gpg("--batch", "--decrypt", str(entry))).hexdigest()


def read_old_backup(path: Path) -> bytes:
    """The retired key's subkeys, from their passphrase-encrypted agenix copy."""
    try:
        sealed = path.read_bytes()
    except PermissionError:
        sealed = run(["sudo", "cat", str(path)], interactive=True)
    return age_decrypt(sealed)


def check_store(store: Path, ring: Keyring, key: Key, digests: dict[Path, str]) -> list[str]:
    """Problems with the re-encrypted store, judged with a keyring that holds only the new key."""
    problems = []
    entries = store_entries(store)
    if entries != sorted(digests):
        problems.append("the set of entries changed during re-encryption")
    for entry in entries:
        try:
            if decrypt_digest(ring, entry) != digests.get(entry):
                problems.append(f"{entry}: the content changed")
        except Abort as error:
            problems.append(f"{entry}: {error}")
    if (store / ".gpg-id").read_text().split() != [key.encrypt]:
        problems.append(f".gpg-id does not name {key.encrypt}")
    # pass accepts the signature when VALIDSIG names a configured key as signer or as primary.
    try:
        status = ring.text(
            "--batch",
            "--status-fd=1",
            "--verify",
            str(store / ".gpg-id.sig"),
            str(store / ".gpg-id"),
        )
        signed = any(
            line.startswith("[GNUPG:] VALIDSIG ") and line.split()[-1] == key.primary
            for line in status.splitlines()
        )
    except Abort:
        signed = False
    if not signed:
        problems.append(".gpg-id.sig is not a signature by the new key")
    if git(store, "status", "--porcelain"):
        problems.append("pass left uncommitted changes")
    return problems


def cmd_pass(args: argparse.Namespace) -> None:
    store = Path(args.store).expanduser()
    if git(store, "status", "--porcelain"):
        raise Abort(f"{store} has uncommitted changes; commit or discard them first")
    head = git(store, "rev-parse", "HEAD")
    entries = store_entries(store)

    prompts = Prompts(
        "the new key backup's age passphrase",
        "the new key's GPG passphrase, in pinentry, to copy it into a work keyring",
        "sudo if the old backup is root-only, then the old backup's age passphrase",
        "the old key's GPG passphrase, in pinentry, once to decrypt every entry",
        "the new key's GPG passphrase, in pinentry, for pass init to sign .gpg-id",
        "the new key's GPG passphrase, in pinentry, once to check every entry",
    )
    with scratch_keyring() as new, scratch_keyring() as work:
        prompts.next()
        key = restore(new, Path(args.backup).expanduser())
        prompts.next()
        import_secret(work, new.gpg("--batch", "--armor", "--export-secret-keys", key.primary))
        prompts.next()
        work.gpg("--batch", "--import", data=read_old_backup(Path(args.old_backup)))

        prompts.next()
        say(f"decrypting all {len(entries)} entries before changing any")
        digests, unreadable = {}, []
        for entry in entries:
            try:
                digests[entry] = decrypt_digest(work, entry)
            except Abort as error:
                unreadable.append(f"{entry}: {error}")
        if unreadable:
            raise Abort("nothing changed; these entries do not open:\n" + "\n".join(unreadable))

        prompts.next()
        say(f"re-encrypting with `pass init {key.encrypt}`")
        env = work.env | {
            "PASSWORD_STORE_DIR": str(store),
            "PASSWORD_STORE_KEY": key.encrypt,
            "PASSWORD_STORE_SIGNING_KEY": key.primary,
        }
        run(["pass", "init", key.encrypt], env=env)

        prompts.next()
        say("checking every entry with a keyring that holds only the new key")
        problems = check_store(store, new, key, digests)
    if problems:
        shown = "\n".join(problems[:10])
        raise Abort(
            f"{len(problems)} problems:\n{shown}\n"
            f"rerun to retry, or roll back with: git -C {store} reset --hard {head}"
        )
    say(f"all {len(entries)} entries open with the new key alone and match their old content")
    say(f"pass committed the switch; review with: git -C {store} log --stat {head}..")
    say(f"until the old key is retired, roll back with: git -C {store} reset --hard {head}")


# --------------------------------------------------------------------------- #
# card
# --------------------------------------------------------------------------- #


@dataclass(frozen=True)
class Card:
    serial: str
    slots: dict[int, str]
    touch: dict[int, bool]


def read_card(ring: Keyring) -> Card:
    serial, slots, touch = "", {}, {}
    for line in ring.text("--card-status", "--with-colons").splitlines():
        fields = line.split(":")
        if fields[0] == "serial":
            serial = fields[1]
        elif fields[0] == "fpr":
            slots = {slot: fields[slot] for slot in (SIG_SLOT, DEC_SLOT)}
        elif fields[0] == "uif":
            touch = {slot: fields[slot] not in ("", "0") for slot in (SIG_SLOT, DEC_SLOT)}
    return Card(serial, slots, touch)


def cmd_card(args: argparse.Namespace) -> None:
    # scdaemon opens the card exclusively; stop the daily one so the scratch keyring's can.
    subprocess.run(["gpgconf", "--kill", "scdaemon"], capture_output=True, check=False)
    with scratch_keyring() as ring:
        card = read_card(ring)
        say(
            f"card {card.serial}: signature slot {card.slots.get(SIG_SLOT) or 'empty'}, "
            f"decryption slot {card.slots.get(DEC_SLOT) or 'empty'}"
        )
        if not (card.touch.get(SIG_SLOT) and card.touch.get(DEC_SLOT)):
            raise Abort(
                "turn on touch for signing and decryption first: in the phone app, or "
                "`gpg --card-edit` → admin → `uif 1 on`, `uif 2 on`"
            )
        prompts = Prompts(
            "the backup's age passphrase",
            "in gpg, at each of the two keytocard: the GPG passphrase in pinentry, then the "
            "OpenPGP Admin PIN, and yes to replace a key already on the card",
            "the OpenPGP PIN, and a touch when the key blinks, to decrypt a probe",
            "the OpenPGP PIN if asked again, and a touch, to sign a probe",
        )
        prompts.next()
        key = restore(ring, Path(args.backup).expanduser())

        number = {part.fingerprint: index for index, part in enumerate(secret_keys(ring)[0])}
        sign, encrypt = number[key.sign], number[key.encrypt]
        prompts.next()
        say("in gpg, type these:")
        for command, effect in (
            (f"key {sign}", "select the [S] subkey"),
            ("keytocard", "choose 1, Signature key"),
            (f"key {sign}", "deselect it"),
            (f"key {encrypt}", "select the [E] subkey"),
            ("keytocard", "choose 2, Encryption key"),
            ("save", ""),
        ):
            print(f"    {command:<12}{effect}", flush=True)
        subprocess.run([GPG, "--edit-key", key.primary], env=ring.env, check=False)

        card = read_card(ring)
        tokens = {part.fingerprint: part.token for part in secret_keys(ring)[0]}
        moved = card.serial and all(card.serial in tokens[fpr] for fpr in (key.sign, key.encrypt))
        if card.slots != {SIG_SLOT: key.sign, DEC_SLOT: key.encrypt} or not moved:
            raise Abort("the [S] and [E] subkeys are not on this card, or gpg did not `save`")
        check_card(ring, key, prompts)
    say(f"card {card.serial} signs and decrypts with the new key")


def check_card(ring: Keyring, key: Key, prompts: Prompts) -> None:
    """Sign and decrypt once through the card; the keyring holds only stubs after keytocard."""
    probe = b"gpg-canokey probe\n"
    sealed = ring.gpg("--batch", "--encrypt", "--recipient", key.encrypt, data=probe)
    prompts.next()
    if ring.gpg("--batch", "--decrypt", data=sealed) != probe:
        raise Abort("the card decrypted the probe to different bytes")
    prompts.next()
    signature = ring.home / "probe.sig"
    signature.write_bytes(
        ring.gpg("--batch", "--local-user", key.primary, "--detach-sign", data=probe)
    )
    status = run(
        [GPG, "--batch", "--status-fd=1", "--verify", str(signature), "-"], env=ring.env, data=probe
    ).decode()
    if not any(line.startswith(f"[GNUPG:] VALIDSIG {key.sign} ") for line in status.splitlines()):
        raise Abort("the card's signature does not verify against the [S] subkey")


# --------------------------------------------------------------------------- #
# entry point
# --------------------------------------------------------------------------- #


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    commands = parser.add_subparsers(dest="command", required=True)

    def add(
        name: str, handler: Callable[[argparse.Namespace], None], help: str
    ) -> argparse.ArgumentParser:
        command = commands.add_parser(name, help=help)
        command.set_defaults(handler=handler)
        return command

    generate = add("generate", cmd_generate, "create the key and its backup")
    generate.add_argument("--uid", required=True, help="such as 'Name (pass) <address>'")
    generate.add_argument(
        "--dest", action="append", required=True, help="directory for one backup copy; repeat it"
    )
    generate.add_argument("--public-key", required=True, help="new file for the public key")

    store = add("pass", cmd_pass, "re-encrypt the password store to the new key")
    store.add_argument("--backup", required=True, help="backup written by `generate`")
    store.add_argument(
        "--old-backup",
        required=True,
        help="the retired key's age-encrypted secret subkeys",
    )
    store.add_argument(
        "--store",
        default=os.environ.get("PASSWORD_STORE_DIR", "~/.local/share/password-store"),
    )

    card = add("card", cmd_card, "load the subkeys onto the plugged-in CanoKey")
    card.add_argument("--backup", required=True, help="backup written by `generate`")
    return parser


def main(argv: list[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    try:
        args.handler(args)
    except (Abort, OSError) as error:
        print(f"gpg_canokey: {error}", file=sys.stderr, flush=True)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
