# Dotfiles sync (encrypted, Nix-independent)

> Status: **design agreed, tool not implemented yet.** This file is the design and the boundary
> document. Agent-facing rules and the procedure live in [`AGENTS.md`](./AGENTS.md).

Some config files hold secrets, are edited in place, and are needed on more than one machine. They
are not a good fit for Nix, and they are not a good fit for a public repository. This directory
documents the mechanism that keeps them in sync across hosts as age ciphertext in the private
`nix-secrets` repository.

## The inclusion test

A file belongs here only if **all three** hold:

1. **It cannot go in a public repository** — it carries a key, token, subscription URL, or private
   endpoint.
2. **It is edited in place** — by hand with `$EDITOR`, or by the tool that owns it.
3. **The edit has to travel back** — another machine needs the edited version.

Anything that fails test 1 belongs in this repository as plain, Nix-managed config. Anything that
fails test 3 is local state and is allowed to be lost. Apply the test when adding an entry; do not
add a file just because it is a dotfile.

This is why the set is small: 12 entries, about 430 KB, of which 420 KB is the mihomo subscription
snapshots.

## Why this exists next to agenix

agenix deploys a **read-only copy** under `/run/agenix/`, one direction: repository → host. Every
file in scope here is written by something other than the repository — `sources.yaml` is edited by
hand, `vinput` and `codex` rewrite their own config — so a read-only copy does not work. This
mechanism is bidirectional: pull, edit, push.

It is deliberately independent of Nix. It has to run on a machine that has no Nix yet (a fresh
install, or the `suzi` gateway, which is not a host in this flake), and it must not depend on an
activation. It needs only `age`, `git`, and `sha256sum`.

| Mechanism | Owns                                         | Direction   |
| --------- | -------------------------------------------- | ----------- |
| Nix / HM  | config that can be public                    | one-way     |
| agenix    | secrets read by services, deployed read-only | one-way     |
| **this**  | secret-bearing config edited in place        | **both**    |
| restic    | bulk data, opaque, host-local                | backup only |

## In scope

Measured, not guessed — the secret-bearing fields were checked in the live files.

| Path                              | Scope         | Secret material found                      |
| --------------------------------- | ------------- | ------------------------------------------ |
| `.config/mihomo/sources.yaml`     | shared, linux | `password`, `secret`, `subscription`, url  |
| `.config/mihomo/snapshots/`       | shared, linux | decoded subscriptions: 37 / 49 / 311 nodes |
| `.codex/config.toml`              | shared        | `api_key`, `subscription`, url             |
| `.codex/config.toml.alva`         | shared        | `api_key`, `token`, url                    |
| `.config/opencode/opencode.jsonc` | shared        | `apikey`, `secret`, `token`                |
| `.config/opencode/service.json`   | shared        | `password`                                 |
| `.config/vinput/config.json`      | **host**      | `api_key` (per-machine key and URLs)       |
| `.kube/config`                    | shared        | `client-key-data`                          |
| `.aliyun/config.json`             | shared        | access key / secret                        |
| `.context7/credentials.json`      | shared        | credentials                                |
| `.dsh/.credentials.yaml`          | shared        | `secret`                                   |
| `.config/zed/settings.json`       | shared        | `token` (the one judgement call)           |

`shared` means one authoritative copy synced to every host. `host` means the file genuinely differs
per machine and lives under `hosts/<host>/`.

## Never in scope

- **Roots of trust**: `~/.ssh` private keys, `~/.gnupg/private-keys-v1.d`, the pass store. They are
  already individual secrets under `backups/` in `nix-secrets`, and putting the keys that decrypt
  the store inside what the store encrypts is a loop, not a backup.
- **Generated files**: `~/.config/mihomo/config.yaml` comes from `generate.nu` plus
  [`modules/nixos/desktop/networking/mihomo/policy.yaml`](../modules/nixos/desktop/networking/mihomo/policy.yaml).
  Syncing it would fight the generator.
- **Tool state and caches**:
  `~/.codex/{history.jsonl,*.sqlite,logs_*,models_cache.json,installation_id,cache,plugins,packages}`,
  `~/.dsh/{sessions,storages,logs,cache,attachments}`, `~/.pi/agent/sessions`, `nushell/history*`,
  any `*.bak-*`.
- **Anything not secret**: `.codex/hooks.json`, `.codex/rules/default.rules`,
  `.config/opencode/{cli.json,themes}`, `.config/gh/*` (no token found), `.dsh/profiles/*`,
  `.agents/skills/**`. These belong in this repository or are disposable.
- **Already Nix-managed**: `.ssh/config` is a real 0600 file on Linux on purpose
  ([`home/base/tui/ssh.nix`](../home/base/tui/ssh.nix) copies it out of the store to dodge the
  bubblewrap `nobody` ownership check), and `~/.gnupg/gpg.conf` is a home-manager symlink. Both look
  unmanaged and neither is.

## Layout

Ciphertext lives in the private repository, never here. This directory holds the documentation and
the `just` wrapper, mirroring how [`secrets/`](../secrets/README.md) relates to `nix-secrets`.

```
~/codes/nix-secrets/dotfiles/
├── manifest.txt           # one line per entry: "+ path", "+ host: path", "+ os:linux path"; trailing / = directory
├── recipients.txt         # generated from desktop_keys in ../secrets.nix
├── sync.sh                # the tool: POSIX sh + age + git + sha256sum
├── home/...               # shared entries, mirroring paths relative to $HOME
└── hosts/<host>/home/...  # host-scoped entries only
```

`dotfiles/` is **not** registered in `secrets.nix`, so `agenix -r` never touches it and changing a
recipient needs no rekey — the next push encrypts to the current `recipients.txt`. Nothing in this
flake consumes `dotfiles/`, so a dotfiles change **needs no `flake.lock` bump**. That is a
deliberate exception to the three-step order in
[`.agents/skills/nix-config-secrets/SKILL.md`](../.agents/skills/nix-config-secrets/SKILL.md); do
not confuse the two flows.

## The sync algorithm

The dangerous failure mode is the whole-tree clobber: `nix-secrets` is amended and force-pushed, and
a machine that has been offline for a week would revert every other machine's changes in one push.
The tool exists mainly to prevent that.

Per entry, three hashes decide everything:

| Name     | Source                                                           |
| -------- | ---------------------------------------------------------------- |
| `base`   | `~/.local/state/dot-sync/base.json`, local only, never committed |
| `local`  | `sha256sum` of the file under `$HOME`                            |
| `remote` | the version in `origin/main`                                     |

1. `git fetch`.
2. `local != base` → this machine changed the file.
3. `origin/main` blob hash vs `HEAD` blob hash → cheap hint for "did anyone else push". Equal means
   definitely unchanged, so the common path **decrypts nothing and needs no sudo**.
4. Only when the blob differs, decrypt that one file and compare plaintext. The tool re-encrypts
   only files whose plaintext changed, so a blob change almost always means a real change.
5. Both sides changed → **conflict: refuse, print the plaintext diff, require `--take-local` or
   `--take-remote`**. Never merge ciphertext, never silently overwrite.
6. On success, rewrite `base`.

Commands: `status`, `pull`, `push`, `diff <path>`, `audit`. `pull` writes `.bak` next to anything it
replaces and **skips symlinks** — overwriting a home-manager symlink would bake a `/nix/store` path
into `$HOME`.

One age-specific trap drives the design: age uses a random nonce, so encrypting identical plaintext
produces different ciphertext. Without the plaintext hash gate, every push would dirty all 12 files
and the diff would be noise.

## Encryption and recipients

Recipients are the keys agenix already uses: `desktop_keys` from `secrets.nix`, which already
includes the offline `recovery_key`. `recipients.txt` is generated from that list so there is one
source of truth for keys, not two hierarchies.

Decryption uses the host SSH key (`sudo age -i /etc/ssh/ssh_host_ed25519_key`), same as
`just -f secrets/Justfile edit`. No user key is added as a recipient: these files are already
readable by anything running as you, so a user key narrows no boundary and adds a private key that
nothing backs up.

## Restore on a new host

1. On the new host: `sudo ssh-keygen -A`, read `/etc/ssh/ssh_host_ed25519_key.pub`.
2. On a trusted desktop: add it to `desktop_keys` in `secrets.nix` and to `recipients.txt`. agenix
   secrets need `just -f secrets/Justfile rekey`; `dotfiles/` does not.
3. On the new host: `sync.sh pull`.

If the host must be restored before it is a recipient, decrypt once with the offline `recovery_key`
(passphrase-protected), then do the above. On a non-NixOS machine such as `suzi`, install a static
`age` binary under `/usr/local/bin` — the same arrangement as the mihomo binary there.

## History and rollback

`nix-secrets` is amended and force-pushed on purpose; there is no usable git history here, and that
is not a gap. Rollback comes from restic: `~/codes` is in the restic `paths` of
[`hosts/idols-ai/restic.nix`](../hosts/idols-ai/restic.nix), so the `nix-secrets` clone — including
`.git` — is snapshotted daily 3 / weekly 2 / monthly 2. A snapshot taken before a force-push is the
time machine. See [BACKUP.md](../BACKUP.md).

## What this retires

- `~/codes/learn-ai`'s `agent-config-backup/`, `scripts/agent-config-backup.nu`, its four `just`
  recipes, and its 15-check test. Delete them in the change that completes the migration, and record
  the removal condition in [WORKAROUNDS.md](../WORKAROUNDS.md).
- The `__REDACTED__` redaction and the "fill the API keys back in by hand after restore" step. They
  existed only because `learn-ai` is a public repository. Under age they add friction and no
  security.
- The manual `rsync` of `~/.config/mihomo`.

restic keeps its role. The boundary: restic is data (bulk, opaque, needs the repository password);
this is config (small, portable, decryptable by a host key). Note that `~/.config` is in neither
restic's `paths` nor home-manager, which is the gap this closes.

## Known risks

- **age has no forward secrecy.** If a recipient key is compromised, every historical version of
  these files — including the ones in restic snapshots — is readable. `rekey` re-encrypts current
  files only. Response: rotate the credentials, and treat the history as burned.
- **The manifest is hand-maintained and will drift.** `audit` lists files under `$HOME` that look
  secret-bearing and are not in the manifest; read it when it fires.
- **Force-push means no in-repo undo.** The base-hash check prevents clobbering other machines, not
  your own bad edit. `pull` keeps `.bak`; restic covers the rest.
- **The set should shrink.** Before adding an entry, ask whether the file could be Nix-managed with
  the secret factored out into an agenix secret. Prefer that.
