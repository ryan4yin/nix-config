# AGENTS.md

Encrypted, bidirectional sync of secret-bearing config that cannot live in this public repository.
Design, boundaries, and the inclusion test are in [README.md](./README.md). Ciphertext lives only in
`~/codes/nix-secrets/dotfiles/` — never here; this directory holds documentation and the `just`
wrapper.

## Hard rules

1. **Never read, print, copy, or stage the plaintext** of a synced file. These files are live
   credentials for running tools. Prove a change with metadata (`sha256sum`, `stat -c '%a %U'`,
   mtime) or with `sync.sh diff` — never with `cat`, `head`, or an editor.
2. **Never copy a `.age` file into this repository.** Same rule as the agenix store.
3. **`dotfiles/` is not an agenix store.** It is not registered in `secrets.nix`: do not add entries
   there, do not run `agenix -r` for it, and do not bump `flake.lock` for a dotfiles change. The
   agenix flow (`.agents/skills/nix-config-secrets/SKILL.md`) is a separate flow with a different
   order of operations; do not merge the two.
4. **Apply the inclusion test before adding an entry** (README § The inclusion test). If the file is
   not secret, it belongs in this repository via home-manager. If it is secret but only read at
   runtime, it belongs in agenix. If it is secret and not needed on another machine, leave it alone.
   State which test the file fails.
5. **Never add a root of trust**: `~/.ssh` private keys, `~/.gnupg/private-keys-v1.d`, the pass
   store. They are already separate secrets under `backups/` in `nix-secrets`.
6. **Never merge ciphertext and never overwrite on conflict.** Stop, show the plaintext diff, and
   ask which side wins. Silent last-writer-wins is the failure this tool exists to prevent.
7. **Never write through a symlink.** `pull` skips symlinks and reports them; overwriting a
   home-manager symlink bakes a `/nix/store` path into `$HOME`.
8. **Amend, force-push, and `git gc --prune=now` in `nix-secrets` are impactful** — get
   authorization first. The repository's habit is amend + force-push, and rollback comes from
   restic, not git.
9. **The tool does not exist yet.** `sync.sh` is specified in the README, not implemented. If asked
   to run the flow, say so and build it first; do not improvise commands by hand against live
   credentials.

## Procedure

Add or change an entry:

1. Edit `manifest.txt` in `~/codes/nix-secrets/dotfiles/` (`+ path`, `+ host: path`,
   `+ os:linux path`, trailing `/` for a directory).
2. `sync.sh status` — confirm only the intended entries appear. Anything else is drift; stop.
3. `sync.sh push` — encrypts to `recipients.txt`, one commit, push. No sudo unless a real conflict
   needs decryption.
4. `sync.sh status` again — must be empty. A non-empty result means the push did not land.
5. On a second host: `sync.sh pull --dry-run` — the entry must be listed.

New host: `sudo ssh-keygen -A` there → add the host public key to `desktop_keys` in `secrets.nix`
**and** to `recipients.txt` (agenix secrets need `just -f secrets/Justfile rekey`; `dotfiles/` does
not) → `sync.sh pull` on the new host. Before it is a recipient, decrypt once with the offline
`recovery_key`.

## Verify without reading

- `sync.sh status` empty after a push, and `pull --dry-run` on another host lists the entry.
- Compare `sha256sum` of the live file against the base cache, not against the ciphertext.
- Restore drill into a throwaway directory under `/dev/shm`, compare hashes, discard. An unverified
  restore is not a backup ([BACKUP.md](../BACKUP.md)).

## Where things live

| Piece                                       | Location                                                   |
| ------------------------------------------- | ---------------------------------------------------------- |
| Design, boundaries, inclusion test          | [README.md](./README.md)                                   |
| Manifest, recipients, `sync.sh`, ciphertext | `~/codes/nix-secrets/dotfiles/` (private)                  |
| Recipient keys                              | `desktop_keys` in `~/codes/nix-secrets/secrets.nix`        |
| Decryption identity                         | `/etc/ssh/ssh_host_ed25519_key` (sudo)                     |
| Rollback                                    | restic snapshot of `~/codes/nix-secrets`                   |
| Being replaced                              | `~/codes/learn-ai` `agent-config-backup/` + mihomo `rsync` |
