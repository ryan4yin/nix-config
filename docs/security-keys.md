# Hardware security keys

How the CanoKey (or a YubiKey) is set up and used on the desktops: initial setup, adding a backup
key, and recovery. Commands here are the single source; the Nix files only point to this page.

Scope: **idols-ai** and **shoukei** (`modules.desktop.canokey.enable`). frieren only shares the
GnuPG `scdaemon` setting. Servers never see a key; they only ask the forwarded agent for sudo.

## Principle

Management and use happen on different devices.

- **PCs only use the key:** WebAuthn/passkeys, sudo, SSH, LUKS unlock and OpenPGP (pass).
- **Management happens only in the phone app** (CanoKey Console on iOS/Android): every PIN change,
  touch policies, application and factory reset, device settings. The CanoKey Admin PIN is never
  typed on a PC; the OpenPGP Admin PIN is typed once, for `keytocard`.
- Sandboxed browsers see only the FIDO HID interface, never raw USB or CCID, so the WebUSB console
  is unreachable from them ([hardening](../hardening/README.md)). Unsandboxed software is trusted;
  if it is malicious, the PC is compromised regardless.

| Use          | Config                                                                                                                 | Fallback without the key                                         |
| ------------ | ---------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| Browsers     | [nixpak FIDO2 passthrough](../hardening/nixpaks/default.nix)                                                           | site recovery codes, other registered key                        |
| sudo, polkit | [canokey.nix](../modules/nixos/desktop/canokey.nix), registrations in [vars](../vars/default.nix) `canokeyU2fKeys`     | password                                                         |
| sudo via SSH | [ssh-agent-sudo.nix](../modules/nixos/server/ssh-agent-sudo.nix), keys in [vars](../vars/default.nix) `canokeySshKeys` | password                                                         |
| SSH          | [ssh.nix](../home/base/tui/ssh.nix), public keys in [vars](../vars/default.nix) `mainSshAuthorizedKeys`                | the other CanoKey; root also accepts the `romantic` recovery key |
| shoukei LUKS | [hardware-configuration.nix](../hosts/12kingdoms-shoukei/hardware-configuration.nix) `crypttabExtraOpts`               | passphrase (prompted after 10 s)                                 |
| pass / GPG   | [gpg](../home/base/tui/gpg/default.nix) `scdaemonSettings.disable-ccid`                                                | the age-encrypted key backup                                     |

Only sudo and polkit accept a touch. Login (greetd), the lock screen and every other PAM service
stay password-based: the login password also unlocks GNOME Keyring.

### PIN and touch per operation

Who decides differs by application:

- **FIDO2** (WebAuthn, sudo, SSH, LUKS): the key stores no touch or PIN policy. Each request says
  whether it needs a touch (user presence) and the FIDO2 PIN (user verification); the key only
  enforces what was asked. The one on-key factor is that a FIDO2 PIN is set.
- **OpenPGP** (pass, GPG): the key enforces its own policies, whatever gpg asks for; see
  [OpenPGP settings on the key](#openpgp-settings-on-the-key).

Touch is enforced only over USB; over NFC nothing asks for one (section 1.2). Once section 2 is
done:

| Operation                                | PIN                                                            | Touch                | Decided by                                                                    |
| ---------------------------------------- | -------------------------------------------------------------- | -------------------- | ----------------------------------------------------------------------------- |
| WebAuthn in browsers                     | FIDO2 PIN, unless the site discourages user verification       | every operation      | request: the site's `userVerification`; "preferred" asks for the PIN once set |
| sudo, polkit (pam-u2f)                   | none                                                           | every prompt         | request: registration `+presence`, no `pinverification`                       |
| sudo on a server (pam_rssh)              | none                                                           | every sudo           | request: same as SSH                                                          |
| SSH login, git over SSH                  | none; FIDO2 PIN only for `ssh-keygen` creation and `-K` export | every new connection | request: key created without `-O verify-required`; details in [SSH](#ssh)     |
| shoukei LUKS                             | FIDO2 PIN                                                      | every boot           | request: `systemd-cryptenroll` default                                        |
| OpenPGP decrypt (pass, browserpass)      | OpenPGP PIN, once per plug-in                                  | every decryption     | key: DEC touch, cache time                                                    |
| OpenPGP sign (`pass init`, `gpg --sign`) | OpenPGP PIN, **every signature**                               | every signature      | key: signature PIN, SIG touch, cache time                                     |
| OpenPGP authenticate                     | OpenPGP PIN, once per plug-in                                  | every use            | key: AUT touch, cache time; unused, SSH uses the FIDO2 key                    |

Little here signs: git commit signing is off, and pass signs only `.gpg-id` on `pass init` (checking
that signature uses the public key, not the card).

#### OpenPGP settings on the key

Stored on the CanoKey, so they follow it to every machine and survive a gpg reinstall; an OpenPGP
application reset returns them to the defaults.

| Setting               | CanoKey default        | Set to | Effect                                                                                                                                | Change with                                                      |
| --------------------- | ---------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------- |
| Signature PIN         | forced                 | forced | forced: PIN for every signature. Not forced: PIN for the first signature after plug-in                                                | `gpg --card-edit` → `admin` → `forcesig` (toggles)               |
| Touch for SIG/DEC/AUT | off                    | on     | a touch for every operation with that key, unless cached                                                                              | `gpg --card-edit` → `admin` → `uif 1 on` (`2` DEC, `3` AUT)      |
| Touch cache time      | 0 s (no cache)         | 0 s    | one value for all three keys, 0–255 s: after a touch, operations within that many seconds need none. 0: every operation needs a touch | phone app; gpg has no command for it                             |
| PIN retries           | 3 (PIN, Admin PIN, RC) | 3      | see [1.1](#11-replace-every-default-secret-first)                                                                                     | firmware 3.1.0+ only (1–15), and it resets the PIN and Admin PIN |
| PIN state             | —                      | —      | after one PIN entry, decrypt and authenticate need none until the key is unplugged                                                    | not configurable                                                 |

- Use `uif N on`, never `permanent`: a permanent touch policy cannot be turned off again, only
  cleared by resetting the OpenPGP application.
- A non-zero cache time lets anything holding the gpg-agent socket (browserpass included) decrypt
  silently for that window after each touch; 0 keeps one touch per decryption.
- Check the key: `gpg --card-status` shows `Signature PIN` and `UIF setting`, but not the cache
  time.

## 1. Device setup

### 1.1 Replace every default secret first

Each application has its own secrets: separate values, separate retry counters (3 on released
firmware), and blocking one does not affect the others. The defaults are public (from the
[CanoKey user guide](https://docs.canokeys.org/userguide/)), so change all of them in the phone app
(CanoKey Console) **before using the key for anything**, including applications you do not use: with
a default PIN or management key, anyone holding the key can use or rewrite that application.

| Application | Secret                | Default                | Protects                                                   | Set it to                                                             | Typed           |
| ----------- | --------------------- | ---------------------- | ---------------------------------------------------------- | --------------------------------------------------------------------- | --------------- |
| Device      | **CanoKey Admin PIN** | `123456`               | settings, per-application and factory reset                | random, 8+ characters (6–64); save offline                            | phone only      |
| WebAuthn    | **FIDO2 PIN**         | unset                  | passkeys, LUKS unlock, SSH key creation and export         | memorable, 6+ characters (4–63); memorize                             | daily, browsers |
| OpenPGP     | **PIN**               | `123456`               | decrypt (pass), sign, authenticate                         | memorable, 6+ characters (6–64), not the FIDO2 PIN; memorize          | daily, pinentry |
| OpenPGP     | **Admin PIN**         | `12345678`             | key import (`keytocard`), touch policy, unblocking the PIN | random, 8+ characters (8–64); save offline                            | setup only      |
| OpenPGP     | Reset Code            | unset                  | unblocking the PIN without the Admin PIN                   | leave unset (the Admin PIN also unblocks), or random and save offline | recovery only   |
| PIV         | PIN / PUK             | `123456` / `12345678`  | PIV keys / unblocking the PIV PIN                          | 8 random digits each (maximum 8); do not save                         | never           |
| PIV         | management key        | `0102030405060708` × 3 | writing PIV keys and certificates                          | the app's random management key button; do not save                   | never           |
| OATH        | none: no password     | —                      | anyone holding the key can read its TOTP/HOTP codes        | —                                                                     | —               |

- **Every PIN locks after 3 wrong attempts, so length matters less than not reusing a value.
- Generate the random values with the phone's password manager;
- "save offline" means that password manager or paper, never `pass`: `pass` itself is decrypted by
  this key.
- The FIDO2 PIN is typed into browsers, the least trusted place, so it must not also unlock pass.

PIV is unused, so its secrets are random and discarded: PIV is then locked rather than open with
public defaults. To use PIV later, reset just the PIV application in the phone app (needs only the
CanoKey Admin PIN), which restores the defaults.

### 1.2 Firmware and settings (phone app)

Touch policies are enforced **only over USB, not NFC**. OpenPGP and PIV stay reachable over NFC on
released firmware, but each NFC tap is a new card session, so their PINs are still required.

Firmware must be 3.0.2 or later. Settings marked 3.1.0+ appear only on that firmware:

| Setting                                              | Choice                                        | Why                                                                       |
| ---------------------------------------------------- | --------------------------------------------- | ------------------------------------------------------------------------- |
| LED                                                  | on                                            | an unexpected blink means something requested a touch                     |
| WebUSB login page                                    | off                                           | the console is not used on PCs                                            |
| NDEF                                                 | read-only                                     | default is enabled; anyone nearby can read it, and rewrite it if writable |
| OpenPGP / PIV over NFC (3.1.0+)                      | off, unless the phone needs OpenPGP           | touch is not enforced over NFC                                            |
| Password/HOTP keyboard output, PIV switches (3.1.0+) | off unless used                               | smaller attack surface                                                    |
| WebAuthn `alwaysUv` (3.1.0+)                         | off                                           | on breaks U2F, which sudo uses                                            |
| WebAuthn minimum PIN length (3.1.0+)                 | 6–8                                           | the PIN locks after a few failures                                        |
| Long-press reset (3.1.0+)                            | off, unless the app documents it as PIN-gated | keeps reset a phone-side management action                                |

### 1.3 Touch feedback

The LED is easy to miss, so touch requests also raise a desktop notification: a transient toast (and
a notification sound, this sender only) that closes itself once the touch is done.
`programs.yubikey-touch-detector` ([canokey.nix](../modules/nixos/desktop/canokey.nix)) reads the
FIDO interface's hidraw reports for touch-waiting signals, and proxies `gpg-agent` for
smartcard-backed OpenPGP operations; the sound comes from Noctalia's notification filter
([config.toml](../home/linux/gui/base/noctalia/config/config.toml)).

| Flow                                   | Notified | Why                                                   |
| -------------------------------------- | -------- | ----------------------------------------------------- |
| sudo (pam-u2f)                         | yes      | CTAPHID keepalive / U2F `0x6985` from the FIDO hidraw |
| ssh/scp/rsync/git over ssh (FIDO2 key) | yes      | same                                                  |
| sudo on a server (pam_rssh)            | yes      | same; the forwarded agent signs on the local key      |
| WebAuthn in browsers                   | yes      | same; browsers read the same hidraw interface         |
| pass / GPG decrypt and sign            | yes      | gpg-agent proxy; heuristic, see below                 |
| PIV / OATH                             | no       | the detector has no source for those applets          |
| shoukei LUKS unlock                    | no       | initrd, before any desktop user service               |
| PIN prompts                            | no       | a PIN is not a touch; pinentry shows that prompt      |

A `switch` only enables the service for the next login: a running session does not start newly
deployed user services, so after the first deploy start it once with
`systemctl --user start yubikey-touch-detector`.

Check it: `systemctl --user status yubikey-touch-detector`, then run something that asks for a touch
(`sudo true`, or `ssh` to a host) and watch for the toast. Logs:
`journalctl --user -u yubikey-touch-detector -f`. The GPG detector only starts once
`private-keys-v1.d` holds on-card stubs, and it treats an operation pending for 400 ms outside
pinentry as a touch request. It proxies only the standard `gpg-agent` and `$SSH_AUTH_SOCK` sockets,
so clients that use `S.gpg-agent.extra` or `S.gpg-agent.browser` get no notification.

## 2. Enroll a key

Only after section 1.1. Do these in order; each step can be rolled back on its own. Only the OpenPGP
step is irreversible.

### Browsers (WebAuthn / passkeys)

Nothing to enroll on the PC. Register the key on each site, preferably as a passkey. After a first
deploy via `switch` without reboot, see the FIDO2 notes in the
[hardening README](../hardening/README.md#limits).

### sudo

```bash
# pamu2fcfg is installed once canokey.nix is deployed; before that:
# Long options: some nix versions expand short flags such as -i after --command.
nix shell nixpkgs#pam_u2f --command \
  pamu2fcfg --nouser --origin=pam://ryan4yin   # touch the key
```

Add the printed `KeyHandle,PublicKey,es256,+presence` string to `canokeyU2fKeys` in
[vars/default.nix](../vars/default.nix) (public data; a leading `:` is accepted) and deploy. sudo
then shows "Please touch the device"; without the key it asks for the password. While the list is
empty, sudo is unchanged.

Every host shares the origin `pam://ryan4yin`, so one registration covers idols-ai and shoukei.

### sudo via SSH

Servers and agent hosts (`modules/nixos/server/ssh-agent-sudo.nix`) run pam_rssh: sudo there sends a
challenge back through the forwarded agent, and the CanoKey signs it after a touch. Nothing to
enroll beyond the SSH key below. Only the `canokeySshKeys` count, so a file key in the agent cannot
satisfy sudo. Agent forwarding is on for `192.168.*` and the `hostsAddr` aliases
([ssh.nix](../home/base/tui/ssh.nix)); without a forwarded agent, or with the key unplugged, sudo
asks for the password.

While a session is open, root on that server can also use the forwarded agent. Each signature still
needs a touch, so an unexpected blink is the signal to refuse it.

### SSH

One SSH key per CanoKey, used for GitHub and every host, lives on it as a resident credential.
`<name>` is the key's name (`tea` is the main key, `moe` the backup):

```bash
ssh-keygen -t ed25519-sk -O resident -O application=ssh:ryan4yin-<name> -C ryan@canokey-<name> \
  -f ~/.ssh/canokey-<name>
```

On each other desktop, export the handle of every key, one key plugged in at a time:

```bash
cd ~/.ssh && ssh-keygen -K \
  && mv id_ed25519_sk_rk_ryan4yin-<name> canokey-<name> \
  && mv id_ed25519_sk_rk_ryan4yin-<name>.pub canokey-<name>.pub
```

[ssh.nix](../home/base/tui/ssh.nix) lists `~/.ssh/canokey-tea`, then `~/.ssh/canokey-moe`, as the
identities for every host and GitHub. Whichever key is plugged in answers; ssh skips the handle of
an absent key.

What the CanoKey stores, and so what the phone app lists, is fixed by OpenSSH
([sk-usbhid.c](https://github.com/openssh/openssh-portable/blob/master/sk-usbhid.c)):

- **RP ID** = `-O application`, the only label you choose. It must start with `ssh:`
  (`ssh-keygen -K` loads only those), and CanoKey keeps at most 32 bytes of it. Naming it per key
  keeps the exported files of two keys apart.
- **User name and display name** are always `openssh`; no ssh-keygen option changes them.
- The `-C` comment is **not** stored on the key, only in the `.pub` and handle files.

How it works, and what the prompts mean:

- The private key never leaves the CanoKey. `~/.ssh/canokey-<name>` holds only the credential ID,
  application and public key. Every authentication sends the server's challenge to the key, which
  signs it after a touch; with the key unplugged, ssh skips this identity and tries the next one.
- **FIDO2 PIN:** asked only when creating the credential and when exporting it with `-K`, not for
  each login. Adding `-O verify-required` at creation would require the PIN for every login too.
- **Touch:** required for every new connection, including each `git push`/`fetch`. Existing sessions
  and reused connections need none: LAN hosts multiplex for 30 minutes (`ControlMaster` in
  [ssh.nix](../home/base/tui/ssh.nix)). A deploy that opens one connection per host needs one touch
  per host.
- **File passphrase:** leave it empty. Reading the file already takes your user session, and
  software running as you is trusted (see [Principle](#principle)); it could also capture the
  passphrase the next time you type it. A passphrase would cost one prompt per login, not per
  connection: `AddKeysToAgent yes` keeps the unlocked handle in the agent, which still asks the key
  for each signature.

Add the public key to `canokeySshKeys` in [vars/default.nix](../vars/default.nix), which is part of
`mainSshAuthorizedKeys`, and to GitHub. These are the only user keys: without a CanoKey, only root
logins with the `romantic` recovery key (`secondaryAuthorizedKeys`) remain.

### shoukei LUKS

Enroll before deploying the crypttab change:

```bash
systemd-cryptenroll --fido2-device=list   # as the user: shows the key's hidraw node
sudo systemd-cryptenroll --fido2-device=/dev/hidrawN /dev/disk/by-uuid/1c37820e-2501-46e4-bec4-27c28691a5b4
sudo systemd-cryptenroll /dev/disk/by-uuid/1c37820e-2501-46e4-bec4-27c28691a5b4   # list slots
```

Name the hidraw node instead of `--fido2-device=auto`: libfido2 is built with PC/SC support, so root
also finds the key's FIDO applet through pcscd (`pcsc://slot0`) and `auto` stops with "More than one
FIDO device found". Unlocking at boot is unaffected: pcscd does not run in the initrd.

The default enrollment requires the FIDO2 PIN and a touch; keep it that way, since the key often
travels with the laptop. The passphrase slot stays. Reboot to verify. A reset key leaves a dead slot
behind; remove every FIDO2 slot with `--wipe-slot=fido2` (the passphrase slot stays), then enroll
each key again.

### pass (OpenPGP)

The password store is encrypted to the `[E]` subkey named by `PASSWORD_STORE_KEY` in
[password-store](../home/base/tui/password-store/default.nix). The key is a `[C]` primary that never
leaves its backup, with `[S]` and `[E]` subkeys that both CanoKeys hold. The secret key exists only
on the cards and in age-encrypted backups, which also carry the revocation certificate. The key has
its own GPG passphrase too: it stays protected in the tmpfs keyrings whenever a backup is opened,
and age's scrypt covers gpg's weaker S2K against offline guessing.
[gpg_canokey.py](../scripts/gpg_canokey.py) does each step in throwaway keyrings on tmpfs.

A new key replaces the old one outright: the old key decrypts the store once, during the switch, and
is then retired.

**Prepare.** Nothing changes for pass yet.

1. Turn on signature and decryption touch on every CanoKey in the phone app; `card` refuses a key
   without them. Decryption touch matters most: browserpass gives browsers the GPG agent socket, and
   without touch a compromised browser could decrypt the whole store silently after the first PIN.
2. Create the key, with two backup drives mounted:

   ```bash
   python3 scripts/gpg_canokey.py generate --uid '<name> (pass) <address>' \
     --dest /run/media/$USER/<drive-1> --dest /run/media/$USER/<drive-2> \
     --public-key ~/codes/nix-secrets/public/<name>.pub
   ```

   Each command lists its prompts before the first one and announces each prompt as it comes; age
   asks again after a mistyped passphrase. Here gpg asks for the new GPG passphrase in three
   dialogs, one per key, twice each, and once more to export the key; then age asks for the backup
   passphrase twice, and once more to prove that the backup restores. A key without a GPG passphrase
   is refused. Make both passphrases long and random and save them offline like the Admin PIN, never
   in pass. Keep the drives offline and apart.

3. Load each CanoKey, with only that key plugged in:
   `python3 scripts/gpg_canokey.py card --backup <drive>/gpg-<fingerprint>.tar.age`. It prints the
   `gpg --edit-key` commands to type, then signs and decrypts once through the card. `keytocard` is
   the only step that types the OpenPGP Admin PIN on a PC; change it again in the phone app
   afterwards.
4. Prepare, but do not deploy, the configuration change: add the public key to
   `programs.gpg.publicKeys` in [gpg](../home/base/tui/gpg/default.nix), set `PASSWORD_STORE_KEY` to
   the `[E]` fingerprint and `PASSWORD_STORE_SIGNING_KEY` to the primary fingerprint (pass checks
   signatures only against full 40-digit fingerprints).

**Switch**, in one sitting:

1. `python3 scripts/gpg_canokey.py pass --backup <drive>/gpg-<fingerprint>.tar.age --old-backup <old-subkeys.age>`.
   It decrypts every entry with the old key before changing anything, re-encrypts with `pass init`,
   then checks that every entry opens with the new key alone and kept its content.
2. Deploy the configuration change to every host that uses pass. Until a host is deployed it cannot
   read the store, and `pass insert` there still encrypts to the old key.
3. On each host, with a CanoKey plugged in, point the daily keyring's stubs at it:
   `gpg-connect-agent "scd serialno" "learn --force" /bye`, then check `pass show <entry>` (PIN,
   then touch). Push the store after that.

Until the old key is retired, rolling back is `git -C <store> reset --hard <commit>` with the commit
`pass` printed, then reverting the configuration change.

**Retire the old key** once every CanoKey passes `pass show` on every host:

1. Delete its stubs from the daily keyring, `gpg --delete-secret-keys '<subkey-fingerprint>!'` for
   each old subkey, then remove its public key from `programs.gpg.publicKeys`.
2. Stop deploying its subkeys: remove `ryan4yin-gpg-subkeys.priv.age` from
   [nixos.nix](../secrets/nixos.nix) and [darwin.nix](../secrets/darwin.nix), then delete its
   ciphertext and public key from nix-secrets. Older revisions in the store's git history stay
   encrypted to the old key and become unreadable.

To revoke the current key: `age --decrypt <backup> | tar -xOf - revocation.asc | gpg --import`, then
publish the public key.

## 3. Add a backup key

A second CanoKey or a YubiKey works the same way; the module name is CanoKey-specific but nothing in
it is. On a YubiKey, manage settings with Yubico Authenticator or `ykman`; OpenPGP touch is
`ykman openpgp keys set-touch dec on` (and `sig`, `aut`).

| Use          | Backup key step                                                                                                                                                            |
| ------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Device       | Section 1 again                                                                                                                                                            |
| Browsers     | Register it on every site as an additional security key                                                                                                                    |
| sudo         | `pamu2fcfg --nouser --origin=pam://ryan4yin` with only the backup plugged in; append to `canokeyU2fKeys`                                                                   |
| SSH          | Create a resident key on it with the same command and its own `<name>`; add its public key to `canokeySshKeys` and GitHub, and its handle file to the `IdentityFile` lists |
| shoukei LUKS | Run the same `systemd-cryptenroll --fido2-device=/dev/hidrawN` with only the backup plugged in; it takes the next slot                                                     |
| OpenPGP      | `gpg_canokey.py card` with only the backup plugged in. Stubs remember the card serial; after swapping cards run `gpg-connect-agent "scd serialno" "learn --force" /bye`    |

## 4. Lost key or reset

| Situation                            | Action                                                                                                               | Lost                                                                          |
| ------------------------------------ | -------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| Key lost                             | Remove its `canokeyU2fKeys` entry and SSH public keys; `systemd-cryptenroll --wipe-slot=<n>`; remove it on each site | nothing, if a backup key or the passwords remain                              |
| FIDO2 PIN forgotten or locked        | Phone app: reset the WebAuthn application (needs the Admin PIN)                                                      | all passkeys, the SSH resident key, LUKS and sudo enrollments; redo section 2 |
| OpenPGP PIN locked                   | `gpg --card-edit` → `admin` → `passwd`, unblock with the OpenPGP Admin PIN or Reset Code                             | nothing                                                                       |
| All OpenPGP PINs and Reset Code lost | Phone app: reset the OpenPGP application                                                                             | on-card subkeys; run `gpg_canokey.py card` again                              |
| Admin PIN forgotten                  | Exhaust the Admin PIN, then in the app tap Reset and touch the key while the LED blinks, repeating until it stops    | all user data; serial and attestation keys stay                               |

After any reset, rerun sections 1 and 2 for the affected applications.

## References

- [CanoKey user guide](https://docs.canokeys.org/userguide/): settings, WebAuthn, OpenPGP, PIV
- [NixOS wiki: YubiKey](https://wiki.nixos.org/wiki/Yubikey): pam_u2f, `disable-ccid`
- [pam-u2f](https://developers.yubico.com/pam-u2f/), `systemd-cryptenroll(1)`, `crypttab(5)`
- Comparable NixOS configs: cloud-gouv/securix (`modules/pam/u2f.nix`), kclejeune/system,
  joshsymonds/nix-config, wimpysworld/nix-config
