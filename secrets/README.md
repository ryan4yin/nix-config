# Secrets Management

> For Website/App's passwords, see
> [../home/base/tui/password-store](../home/base/tui/password-store/README.md) for more details.

All my secrets are safely encrypted via agenix, and stored in a separate private GitHub repository
and referenced as a flake input in this flake.

The encryption is done using the public keys of all my hosts (`/etc/ssh/ssh_host_ed25519_key`), so
that they can only be decrypted on any of my configured hosts. The host keys are generated locally
on each host by OpenSSH without a passphrase and are only readable by `root`. The host keys will
never leave the host.

In this way, all secrets are still encrypted when transmitted over the network and written to
`/nix/store`. They are decrypted only when they are finally used.

In addition, we further improve the security of secret files by storing them in a separate private
repository.

This directory contains this `README.md`, the `Justfile` with the agenix recipes, and the
`nixos.nix`/`darwin.nix` files that decrypt all my secrets via `agenix`. Then, I can use them in
this flake.

## Two Flows, and Which One a File Belongs To

agenix holds the secrets that barely change and that a Nix module or service reads from the
decrypted path. `flake.lock` pins `mysecrets`, so an agenix secret is a frozen revision: each edit
costs a lock bump plus a rebuild and switch on every host that reads it.

Anything else is a synced dotfile: Nix does not read it, it changes often, or it is a config file
its tool keeps rewriting that happens to carry a few secrets inside. The private repository syncs
those as age ciphertext under `dotfiles/`, by hand and outside Nix, so there is no `secrets.nix`
entry and no lock bump. `nushell-secrets.nu` moved that way and is `~/.secrets/nushell-secrets.nu`
now; do not re-add it to `age.secrets`. The file list stays in the private repository.

## Which Keys Go on a Secret

**Every secret is decryptable by the desktops and by the offline `recovery_key`, and those two have
identical access.** The desktops hold the trusted admin keys and are where secrets are added, edited
and rekeyed — including `agenix -r`, which has to decrypt every secret in this repository first.
`recovery_key` is a member of `desktop_keys`, so one rule covers both: every recipient set is
`desktop_keys ++ <the hosts that need it>`.

That also means a lost host never makes a secret unrecoverable, and that narrowing a set to the
servers alone breaks the desktops and the recovery key together.

The one exception is the desktop's own restic repository password (`restic-password-desktop.age`):
`desktop_keys` alone, because the backup servers must not be able to read desktop data.

## Decrypted File Permissions

Most secrets in `secrets/nixos.nix` and `secrets/darwin.nix` use one of three shared presets; a few
set `mode`/`owner` inline:

| Preset          | Mode / owner    | Use for                                          |
| --------------- | --------------- | ------------------------------------------------ |
| `noaccess`      | `0000` root     | a file nothing reads directly                    |
| `high_security` | `0500` root     | root-only consumers (services, activation)       |
| `user_readable` | `0500` `<user>` | anything a Home Manager module or the user reads |

Secrets are gated by `modules.secrets.<group>.enable`, so a secret only exists on hosts in its
group. A module that consumes it must sit behind the same gate.

Placing a secret under `/etc/agenix/` with `environment.etc` has one trap: setting `mode` makes
`environment.etc` **copy** the file instead of symlinking it, and the copy is owned by root unless
`user` is set too. Widening the mode so the user can read a root-owned copy makes it readable by
every local account. Always set `user` together with `mode`. nix-darwin ignores both on
`environment.etc`, so `secrets/darwin.nix` chowns `/etc/agenix/*` after activation instead.

## Adding or Updating Secrets

> The encrypted `.age` files and `secrets.nix` live in my private `nix-secrets` repository. The
> `Justfile` referenced below lives in this repository and runs its recipes with `working-directory`
> set to a local `~/codes/nix-secrets` checkout, so invoke it from this repository's root.

This task is accomplished using the [agenix](https://github.com/ryantm/agenix) CLI tool with the
`./secrets.nix` file in the private `nix-secrets` repository, so you need to have it installed
first:

To use agenix temporarily, run:

```bash
nix shell github:ryantm/agenix#agenix
```

or agenix provided by ragenix, run:

```bash
nix shell github:ryan4yin/ragenix#ragenix
```

Suppose you want to add a new secret file `xxx.age`. Follow these steps:

1. Navigate to your private `nix-secrets` repository.
2. Edit `secrets.nix` and add a new entry for `xxx.age`, defining the encryption keys and the secret
   file path, for example:

```nix
# This file is not imported into your NixOS configuration. It is only used for the agenix CLI.
# agenix use the public keys defined in this file to encrypt the secrets.
# and users can decrypt the secrets by any of the corresponding private keys.

let
  # Get each desktop's ssh public key with:
  #    cat /etc/ssh/ssh_host_ed25519_key.pub
  # If the file does not exist, generate all host keys with: sudo ssh-keygen -A
  idol_ai = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINHZtzeaQyXwuRMLzoOAuTu8P9bu5yc5MBwo5LI3iWBV root@ai";

  # An offline recovery key, generated with
  # `ssh-keygen -t ed25519 -a 256 -C "ryan@agenix-recovery"` and kept in a safe place.
  recovery_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHnIGH+653Oe+GQaA8zjjj7HWMWp7bWXed4q5KqY4nqG ryan@agenix-recovery";

  # Every secret stays decryptable by the desktops plus the recovery key.
  desktop_keys = [
    idol_ai
    recovery_key
  ];

  # The other hosts that need this specific secret.
  hosts = [ ];
in
{
  "./xxx.age".publicKeys = desktop_keys ++ hosts;
}
```

3. Create the secret file `xxx.age` from this repository's root with the [`Justfile`](./Justfile)
   `replace` recipe, piping the plaintext on stdin:

```shell
just -f secrets/Justfile replace ./xxx.age < plaintext
```

`replace` deletes the target first, so agenix only encrypts to the public keys in `secrets.nix` and
never decrypts the old value — it needs no `sudo`. Use `edit` instead for a partial change to an
existing secret: it decrypts the current value first with the host key
(`/etc/ssh/ssh_host_ed25519_key`), so it needs `sudo`.

```shell
just -f secrets/Justfile edit ./xxx.age
```

`agenix` will encrypt the file with all the public keys we defined in `secrets.nix`, so all the
users and systems defined in `secrets.nix` can decrypt it with their private keys.

After pushing, run `just upp mysecrets` in this repository: `flake.lock` pins `mysecrets`, so a new
or changed file is invisible here until the lock moves. The repo-side steps are in
[`.agents/skills/nix-config-secrets/SKILL.md`](../.agents/skills/nix-config-secrets/SKILL.md).

## Deploying Secrets

> All the operations in this section should be performed in this repository.

First, add your own private `nix-secrets` repository and `agenix` as a flake input, and pass them to
sub modules via `specialArgs`:

```nix
{
  inputs = {
    # ......

    # secrets management, lock with git commit at May 18, 2025
    agenix = {
      url = "github:ryantm/agenix/4835b1dc898959d8547a871ef484930675cb47f1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # my private secrets, it's a private repository, you need to replace it with your own.
    mysecrets = {
      url = "git+ssh://git@github.com/ryan4yin/nix-secrets.git?shallow=1";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }: {
    nixosConfigurations = {
      nixos-test = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        # Set all input parameters as specialArgs of all sub-modules
        # so that we can use the `agenix` & `mysecrets` in sub-modules
        specialArgs = inputs;
        modules = [
          # ......

          # import & decrypt secrets in `mysecrets` in this module
          ./secrets/nixos.nix
        ];
      };
    };
  };
}
```

Then, create `./secrets/nixos.nix` (or `./secrets/darwin.nix` on macOS) with the following content:

```nix
# import & decrypt secrets in `mysecrets` in this module
{ config, pkgs, agenix, mysecrets, ... }:

{
  imports = [
     agenix.nixosModules.default
  ];

  # if you changed this key, you need to regenerate all encrypt files from the decrypt contents!
  age.identityPaths = [
    # using the host key for decryption
    # the host key is generated on every host locally by openssh, and will never leave the host.
    # On a preservation host, use the /persistent path so the key exists at boot:
    # "/persistent/etc/ssh/ssh_host_ed25519_key"
    "/etc/ssh/ssh_host_ed25519_key"
  ];

  age.secrets."xxx" = {
    # whether secrets are symlinked to age.secrets.<name>.path
    symlink = true;
    # target path for decrypted file
    path = "/etc/xxx";
    # encrypted file path
    file =  "${mysecrets}/xxx.age";  # refer to ./xxx.age located in `mysecrets` repo
    mode = "0400";
    owner = "root";
    group = "root";
  };
}
```

From now on, every time you run `nixos-rebuild switch`, it will decrypt the secrets using the
private keys defined in `age.identityPaths`. It will then symlink the secrets to the path defined by
the `age.secrets.<name>.path` argument, which defaults to `/run/agenix/<name>`.

## Adding a new host

1. `cat` the system-level public key(`/etc/ssh/ssh_host_ed25519_key.pub`) of the new host, and send
   it to an old host which has already been configured.
2. On the old host:
   1. Add the public key to `secrets.nix`, then rekey all the secrets:
      `just -f secrets/Justfile rekey`.
   2. Commit and push the changes to `nix-secrets`.
3. On the new host:
   1. Clone this repo and run `nixos-rebuild switch` to deploy it, all the secrets will be decrypted
      automatically via the host private key.
   2. A desktop also needs the synced dotfiles: regenerate their recipient list from `desktop_keys`
      and run the sync's `restore` there before the first switch, so the shell's secret block is
      present when the config sources it. See
      [Two Flows](#two-flows-and-which-one-a-file-belongs-to).

## Troubleshooting

### 1. Nix-Darwin Module

Check logs:

```bash
tail -n 100 /Library/Logs/org.nixos.activate-agenix.stderr.log
tail -n 100 /Library/Logs/org.nixos.activate-agenix.stdout.log
```

### 2. NixOS Module

Check logs:

```
journalctl | grep -5 agenix
```

## Other Replacements

- [ragenix](https://github.com/yaxitech/ragenix): A Rust reimplementation of agenix.
  - agenix is mainly written in bash, and it's error message is quite obscure, a little typo may
    cause some errors no one can understand.
  - with a type-safe language like Rust, we can get a better error message and less bugs.
