"""Runs `generate` and `pass` against real gpg, age and pass; `card` needs a CanoKey."""

from __future__ import annotations

import contextlib
import os
import shutil
import tempfile
import unittest
from collections.abc import Iterator
from pathlib import Path
from unittest import mock

from scripts import gpg_canokey
from scripts.gpg_canokey import (
    Keyring,
    import_secret,
    main,
    run,
    secret_keys,
    store_entries,
    unpack,
)

TOOLS = ("gpg", "gpg-connect-agent", "age", "age-keygen", "pass", "git")
PASSPHRASE = "test passphrase"
OLD_KEY = ("--batch", "--pinentry-mode", "loopback", "--passphrase", PASSPHRASE)
# Answers every pinentry request with PASSPHRASE, in place of the desktop's dialog.
FAKE_PINENTRY = f"""#!/bin/sh
echo OK
while read -r command rest; do
  case $command in
    GETPIN) echo "D {PASSPHRASE}"; echo OK ;;
    BYE) echo OK; exit 0 ;;
    *) echo OK ;;
  esac
done
"""


@unittest.skipUnless(all(map(shutil.which, TOOLS)), f"needs {', '.join(TOOLS)}")
class SwitchTest(unittest.TestCase):
    def setUp(self) -> None:
        # tmpfs, like the script itself.
        self.root = Path(tempfile.mkdtemp(dir=os.environ.get("XDG_RUNTIME_DIR")))
        self.addCleanup(shutil.rmtree, self.root)

        # A passphrase needs a terminal, so the tests encrypt to an age identity instead.
        identity = self.root / "age-identity"
        run(["age-keygen", "-o", str(identity)])
        recipient = run(["age-keygen", "-y", str(identity)]).decode().strip()
        self.age_encrypt = lambda data: run(["age", "-r", recipient], data=data)
        self.age_decrypt = lambda data: run(["age", "-d", "-i", str(identity)], data=data)
        for name, fake in (("age_encrypt", self.age_encrypt), ("age_decrypt", self.age_decrypt)):
            patcher = mock.patch.object(gpg_canokey, name, fake)
            patcher.start()
            self.addCleanup(patcher.stop)

        git_env = {
            "GIT_CONFIG_GLOBAL": "/dev/null",
            "GIT_CONFIG_NOSYSTEM": "1",
            "GIT_AUTHOR_NAME": "test",
            "GIT_AUTHOR_EMAIL": "test@example.org",
            "GIT_COMMITTER_NAME": "test",
            "GIT_COMMITTER_EMAIL": "test@example.org",
        }
        patcher = mock.patch.dict(os.environ, git_env)
        patcher.start()
        self.addCleanup(patcher.stop)

        pinentry = self.root / "pinentry"
        pinentry.write_text(FAKE_PINENTRY)
        pinentry.chmod(0o700)
        real_keyring = gpg_canokey.scratch_keyring

        @contextlib.contextmanager
        def scratch_keyring() -> Iterator[Keyring]:
            with real_keyring() as ring:
                (ring.home / "gpg-agent.conf").write_text(f"pinentry-program {pinentry}\n")
                yield ring

        self.scratch_keyring = scratch_keyring
        patcher = mock.patch.object(gpg_canokey, "scratch_keyring", scratch_keyring)
        patcher.start()
        self.addCleanup(patcher.stop)

        self.store = self.root / "store"
        self.old_backup = self.root / "old-subkeys.age"

    def generate(self) -> Path:
        usb, second = self.root / "usb", self.root / "second"
        usb.mkdir()
        second.mkdir()
        argv = ["generate", "--uid", "New (test) <new@example.org>", "--public-key"]
        argv += [str(self.root / "new.pub"), "--dest", str(usb), "--dest", str(second)]
        self.assertEqual(main(argv), 0)
        [backup] = usb.glob("*.tar.age")
        self.assertEqual(backup.read_bytes(), (second / backup.name).read_bytes())
        return backup

    def make_store(self, plaintexts: dict[str, bytes]) -> None:
        """A store encrypted to an old key whose subkeys are backed up like the retired one."""
        with self.scratch_keyring() as old:
            old.gpg(
                *OLD_KEY,
                "--quick-generate-key",
                "Old <old@example.org>",
                "ed25519",
                "cert,sign",
                "never",
            )
            primary = secret_keys(old)[0][0].fingerprint
            old.gpg(*OLD_KEY, "--quick-add-key", primary, "cv25519", "encr", "never")
            for name, plaintext in plaintexts.items():
                entry = self.store / f"{name}.gpg"
                entry.parent.mkdir(parents=True, exist_ok=True)
                entry.write_bytes(
                    old.gpg(
                        "--batch",
                        "--trust-model",
                        "always",
                        "--encrypt",
                        "-r",
                        primary,
                        data=plaintext,
                    )
                )
            subkeys = old.gpg(*OLD_KEY, "--armor", "--export-secret-subkeys", primary)
        self.old_backup.write_bytes(self.age_encrypt(subkeys))
        (self.store / ".gpg-id").write_text(primary + "\n")
        run(["git", "-C", str(self.store), "init", "--quiet"])
        run(["git", "-C", str(self.store), "add", "-A"])
        run(["git", "-C", str(self.store), "commit", "--quiet", "-m", "old store"])

    def switch(self, backup: Path) -> int:
        argv = ["pass", "--backup", str(backup), "--old-backup", str(self.old_backup)]
        return main([*argv, "--store", str(self.store)])

    def test_store_moves_to_the_new_key(self) -> None:
        backup = self.generate()
        plaintexts = {"alpha": b"secret one\n", "web/beta": b"secret two\nuser: x\n"}
        self.make_store(plaintexts)

        self.assertEqual(self.switch(backup), 0)
        with self.scratch_keyring() as only_new:
            secret, _ = unpack(self.age_decrypt(backup.read_bytes()))
            import_secret(only_new, secret)
            for name, plaintext in plaintexts.items():
                entry = self.store / f"{name}.gpg"
                self.assertEqual(only_new.gpg("--batch", "--decrypt", str(entry)), plaintext)

        # A rerun, as after an interrupted switch, finds nothing left to do.
        self.assertEqual(self.switch(backup), 0)

    def test_unreadable_entry_stops_before_any_change(self) -> None:
        backup = self.generate()
        self.store.mkdir()
        (self.store / "broken.gpg").write_bytes(b"not an OpenPGP message")
        self.make_store({"alpha": b"secret\n"})
        before = {entry: entry.read_bytes() for entry in store_entries(self.store)}
        head = run(["git", "-C", str(self.store), "rev-parse", "HEAD"])

        self.assertEqual(self.switch(backup), 1)
        self.assertEqual({entry: entry.read_bytes() for entry in before}, before)
        self.assertEqual(run(["git", "-C", str(self.store), "rev-parse", "HEAD"]), head)


if __name__ == "__main__":
    unittest.main()
