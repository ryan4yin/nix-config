# Secrets — agent rules

Handling rules for the agenix secret store. The human how-to and concepts are in
[`README.md`](./README.md); the task procedure is in the
[`nix-config-secrets` skill](../.agents/skills/nix-config-secrets/SKILL.md). The ciphertext and the
recipient rules live in the private repository `~/codes/nix-secrets`
(`git@github.com:ryan4yin/nix-secrets.git`), pinned here as the `mysecrets` flake input.

## Never

- Never decrypt, print, copy, or log secret plaintext. `.age` files are ciphertext and safe to
  handle as bytes; the decrypted values are not. No `agenix -d`, and no plaintext in commands, logs,
  or the conversation.
- Never copy a `.age` file into this public repository or commit one. The private `mysecrets` split
  exists precisely so the ciphertext stays out: treat anything published as eventually leaked.
- Never write plaintext into either repository or stage it.
- Never publish the private repository. Its `public/` directory is the only publishable material.

## The private repository

- Every `.age` file has exactly one `secrets.nix` entry, keyed by the exact path string (e.g.
  `"./desktop/xxx.age"`). Moving or renaming a file without updating the key breaks consumers and is
  skipped by rekey.
- Files are grouped: `desktop/` (only desktops decrypt them), `server/` (any server), `certs/`,
  `backups/` (retired/offline material, decrypted manually), `public/`.
- Run `agenix` from that repository's root, where `RULES` defaults to `./secrets.nix`. House
  command: `sudo -E agenix -i /etc/ssh/ssh_host_ed25519_key -e ./<dir>/<file>.age`. Use uppercase
  `-E` (it preserves `$EDITOR`); lowercase `sudo -e` is `sudoedit` and never runs agenix. agenix's
  options go after `agenix`, and `-e` consumes the next argument, so keep `-i` first.
- Recipient groups in `secrets.nix`: `desktop_keys` (desktops plus the offline recovery key),
  `network_server_keys`, `application_server_keys` (aliases `web_`/`storage_`/`operation_`),
  `k8s_server_keys`, and `all_keys`. Pick the narrowest group; desktop-only secrets must stay
  decryptable without the servers.
- After adding or changing a recipient key, rekey everything:
  `sudo -E agenix -r -i /etc/ssh/ssh_host_ed25519_key`, then `sudo chown -R ryan:ryan *`.
- The repository keeps a single amended commit: `git commit --amend -a --no-edit`,
  `git reflog expire --expire-unreachable=now --all`, `git gc --prune=now`, then force push. Treat
  amend and force push as impactful and get authorization first.

## The consumer side (this repository)

- Declare secrets in `secrets/nixos.nix` or `secrets/darwin.nix`, gated by
  `modules.secrets.<group>.enable`, and keep the consumer behind the same gate.
- Three steps, in order: change the private repository, push, bump `mysecrets` in `flake.lock`, then
  declare and consume here. The lock pins the revision, so a declaration that lands first points at
  a file that is not there yet.
- Set `mode` and `user` together: an `environment.etc` entry that sets `mode` copies the file and
  owns it by root unless `user` is set too.
- Verify without reading: `stat -c '%a %U:%G'`, `ls -l /run/agenix/`, and the activation logs.
