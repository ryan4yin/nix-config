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

| Use          | Config                                                                                                                 | Daily use                                | Fallback without the key                  |
| ------------ | ---------------------------------------------------------------------------------------------------------------------- | ---------------------------------------- | ----------------------------------------- |
| Browsers     | [nixpak FIDO2 passthrough](../hardening/nixpaks/default.nix)                                                           | FIDO2 PIN and/or touch, as the site asks | site recovery codes, other registered key |
| sudo         | [canokey.nix](../modules/nixos/desktop/canokey.nix), registrations in [vars](../vars/default.nix) `canokeyU2fKeys`     | touch                                    | password                                  |
| sudo via SSH | [ssh-agent-sudo.nix](../modules/nixos/server/ssh-agent-sudo.nix), keys in [vars](../vars/default.nix) `canokeySshKeys` | touch                                    | password                                  |
| SSH          | [ssh.nix](../home/base/tui/ssh.nix), public keys in [vars](../vars/default.nix) `mainSshAuthorizedKeys`                | touch per connection                     | per-host file keys                        |
| shoukei LUKS | [hardware-configuration.nix](../hosts/12kingdoms-shoukei/hardware-configuration.nix) `crypttabExtraOpts`               | FIDO2 PIN + touch                        | passphrase (prompted after 10 s)          |
| pass / GPG   | [gpg](../home/base/tui/gpg/default.nix) `scdaemonSettings.disable-ccid`                                                | OpenPGP PIN once per plug-in, then touch | off-card subkey backup                    |

Login (greetd) stays password-based: the password also unlocks GNOME Keyring.

## 1. Device setup

### 1.1 Replace every default secret first

Each application has its own secrets: separate values, separate retry counters (3 on released
firmware), and blocking one does not affect the others. The defaults are public (from the
[CanoKey user guide](https://docs.canokeys.org/userguide/)), so change all of them in the phone app
(CanoKey Console) **before using the key for anything**, including applications you do not use: with
a default PIN or management key, anyone holding the key can use or rewrite that application.

| Application | Secret            | Default                | Protects                                                   | Set it to                                                             | Typed           |
| ----------- | ----------------- | ---------------------- | ---------------------------------------------------------- | --------------------------------------------------------------------- | --------------- |
| Device      | CanoKey Admin PIN | `123456`               | settings, per-application and factory reset                | random, 12+ characters (6–64); save offline                           | phone only      |
| WebAuthn    | FIDO2 PIN         | unset                  | passkeys, LUKS unlock, SSH key creation and export         | memorable, 8+ characters (4–63); memorize                             | daily, browsers |
| OpenPGP     | PIN               | `123456`               | decrypt (pass), sign, authenticate                         | memorable, 8+ characters (6–64), not the FIDO2 PIN; memorize          | daily, pinentry |
| OpenPGP     | Admin PIN         | `12345678`             | key import (`keytocard`), touch policy, unblocking the PIN | random, 12+ characters (8–64); save offline                           | setup only      |
| OpenPGP     | Reset Code        | unset                  | unblocking the PIN without the Admin PIN                   | leave unset (the Admin PIN also unblocks), or random and save offline | recovery only   |
| PIV         | PIN / PUK         | `123456` / `12345678`  | PIV keys / unblocking the PIV PIN                          | 8 random digits each (maximum 8); do not save                         | never           |
| PIV         | management key    | `0102030405060708` × 3 | writing PIV keys and certificates                          | the app's random management key button; do not save                   | never           |
| OATH        | none: no password | —                      | anyone holding the key can read its TOTP/HOTP codes        | —                                                                     | —               |

Every PIN locks after 3 wrong attempts, so length matters less than not reusing a value. Generate
the random values with the phone's password manager; "save offline" means that password manager or
paper, never `pass`: `pass` itself is decrypted by this key. The FIDO2 PIN is typed into browsers,
the least trusted place, so it must not also unlock pass.

PIV is unused, so its secrets are random and discarded: PIV is then locked rather than open with
public defaults. To use PIV later, reset just the PIV application in the phone app (needs only the
CanoKey Admin PIN), which restores the defaults.

### 1.2 Firmware and settings (phone app)

Touch policies are enforced **only over USB, not NFC**. OpenPGP and PIV stay reachable over NFC on
released firmware, but each NFC tap is a new card session, so their PINs are still required.

1. Check the firmware version. U2F (sudo) does not work on 3.0.0; 3.0.2 and later are fine. The
   newest public release is canokey-core [3.0.3](https://github.com/canokeys/canokey-core/tags).
2. Settings on released firmware (the user guide lists LED, NDEF and WebUSB login page):

   | Setting           | Choice                                 | Why                                                                       |
   | ----------------- | -------------------------------------- | ------------------------------------------------------------------------- |
   | LED               | on                                     | an unexpected blink means something requested a touch                     |
   | WebUSB login page | off                                    | the console is not used on PCs                                            |
   | NDEF              | off, or read-only if the app offers it | default is enabled; anyone nearby can read it, and rewrite it if writable |

3. The user guide also documents options for **firmware 3.1.0**, which has no public release yet
   (only the docs mention it; canokey-core's `dev` branch is unversioned). If the app shows them:

   | Option                                      | Choice                                        | Why                                        |
   | ------------------------------------------- | --------------------------------------------- | ------------------------------------------ |
   | OpenPGP / PIV over NFC                      | off, unless the phone needs OpenPGP           | touch is not enforced over NFC             |
   | Password/HOTP keyboard output, PIV switches | off unless used                               | smaller attack surface                     |
   | WebAuthn `alwaysUv`                         | off                                           | on breaks U2F, which sudo uses             |
   | WebAuthn minimum PIN length                 | 6–8                                           | the PIN locks after a few failures         |
   | Long-press reset                            | off, unless the app documents it as PIN-gated | keeps reset a phone-side management action |

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

One SSH key, used for GitHub and every host, lives on the key as a resident credential:

```bash
ssh-keygen -t ed25519-sk -O resident -O application=ssh:ryan4yin -C ryan@canokey-<name>
```

This writes `~/.ssh/id_ed25519_sk` on the machine that runs it. On each other desktop, export the
key handle to ssh's default identity:

```bash
cd ~/.ssh && ssh-keygen -K \
  && mv id_ed25519_sk_rk_ryan4yin id_ed25519_sk && mv id_ed25519_sk_rk_ryan4yin.pub id_ed25519_sk.pub
```

How it works, and what the prompts mean:

- The private key never leaves the CanoKey. `~/.ssh/id_ed25519_sk` holds only the credential ID,
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
`mainSshAuthorizedKeys`, and to GitHub. GitHub tries `id_ed25519_sk` before the per-host key; other
hosts try it as a default identity. Keys already loaded in `ssh-agent` are offered first, so the
per-host keys can still win until they are retired.

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
travels with the laptop. The passphrase slot stays. Reboot to verify.

### pass (OpenPGP)

The password store is encrypted to the `[E]` subkey `0xEF824EB73CFD6CC7`; the primary key is
offline.

1. Verify the **off-card backup** of all three subkeys first: `keytocard` replaces the on-disk copy
   with a stub.
2. Move the subkeys: `gpg --edit-key 0xCC88591C033F1924`, then `key 1` → `keytocard` (encryption),
   and likewise for the signing and authentication subkeys; `save`.
3. Require touch for SIG, DEC and AUT in the phone app's OpenPGP page (or on the PC:
   `gpg --card-edit` → `admin` → `uif 1 on`, `uif 2 on`, `uif 3 on`). Decrypt touch matters most:
   browserpass gives browsers the GPG agent socket, and without touch a compromised browser could
   decrypt the whole store silently after the first PIN.
4. On other machines that still hold on-disk copies, delete them
   (`gpg --delete-secret-keys '<subkey-fingerprint>!'`) and run `gpg --card-status` so gpg records
   stubs for the card.

`keytocard` is the only step that types the OpenPGP Admin PIN on a PC; change it again in the phone
app afterwards.

## 3. Add a backup key

A second CanoKey or a YubiKey works the same way; the module name is CanoKey-specific but nothing in
it is. On a YubiKey, manage settings with Yubico Authenticator or `ykman`; OpenPGP touch is
`ykman openpgp keys set-touch dec on` (and `sig`, `aut`).

| Use          | Backup key step                                                                                                                                                                                                                                                  |
| ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Device       | Section 1 again                                                                                                                                                                                                                                                  |
| Browsers     | Register it on every site as an additional security key                                                                                                                                                                                                          |
| sudo         | `pamu2fcfg --nouser --origin=pam://ryan4yin` with only the backup plugged in; append to `canokeyU2fKeys`                                                                                                                                                         |
| SSH          | Create a resident key on it with the same command; add its public key to `canokeySshKeys` and GitHub. Use it with `ssh-add -K` (loads resident keys into the agent) instead of exporting a file                                                                  |
| shoukei LUKS | Run the same `systemd-cryptenroll --fido2-device=auto` with only the backup plugged in; it takes the next slot                                                                                                                                                   |
| OpenPGP      | Import the subkeys from the backup into a fresh, temporary `GNUPGHOME`, `keytocard` them onto the backup key, then delete that `GNUPGHOME`. The stubs remember the card serial; after swapping cards run `gpg-connect-agent "scd serialno" "learn --force" /bye` |

## 4. Lost key or reset

| Situation                            | Action                                                                                                               | Lost                                                                          |
| ------------------------------------ | -------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| Key lost                             | Remove its `canokeyU2fKeys` entry and SSH public keys; `systemd-cryptenroll --wipe-slot=<n>`; remove it on each site | nothing, if a backup key or the passwords remain                              |
| FIDO2 PIN forgotten or locked        | Phone app: reset the WebAuthn application (needs the Admin PIN)                                                      | all passkeys, the SSH resident key, LUKS and sudo enrollments; redo section 2 |
| OpenPGP PIN locked                   | `gpg --card-edit` → `admin` → `passwd`, unblock with the OpenPGP Admin PIN or Reset Code                             | nothing                                                                       |
| All OpenPGP PINs and Reset Code lost | Phone app: reset the OpenPGP application                                                                             | on-card subkeys; re-import from the backup                                    |
| Admin PIN forgotten                  | Exhaust the Admin PIN, then in the app tap Reset and touch the key while the LED blinks, repeating until it stops    | all user data; serial and attestation keys stay                               |

After any reset, rerun sections 1 and 2 for the affected applications.

## Enrollment status

| Key                                    | Firmware | sudo              | SSH                                                     | shoukei LUKS                  | OpenPGP     | Browsers                         |
| -------------------------------------- | -------- | ----------------- | ------------------------------------------------------- | ----------------------------- | ----------- | -------------------------------- |
| CanoKey Canary (backup, `canokey-moe`) | 3.0.3    | works on idols-ai | public key in `canokeySshKeys`; host login not verified | enrolled; unlock not verified | on the card | WebAuthn works in Firefox/Chrome |

shoukei's first boots with the FIDO2 slot asked for the PIN, then fell back to the passphrase: USB
only came up after switch-root, because on linux-asahi 7.2 its dwc3/PHY depend on the Thunderbolt
(ACIO) nodes, whose `thunderbolt_apple` and `reset_apple_cio` drivers were missing from the initrd.
nixos-apple-silicon added both upstream (`275e570ea8`), and the input now includes it; unlocking
with the key is not yet verified. Also not verified: the CanoKey Admin PIN retry count, and how
touch is performed when resetting over NFC.

## References

- [CanoKey user guide](https://docs.canokeys.org/userguide/): settings, WebAuthn, OpenPGP, PIV
- [NixOS wiki: YubiKey](https://wiki.nixos.org/wiki/Yubikey): pam_u2f, `disable-ccid`
- [pam-u2f](https://developers.yubico.com/pam-u2f/), `systemd-cryptenroll(1)`, `crypttab(5)`
- Comparable NixOS configs: cloud-gouv/securix (`modules/pam/u2f.nix`), kclejeune/system,
  joshsymonds/nix-config, wimpysworld/nix-config
