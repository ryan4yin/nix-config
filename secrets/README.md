# secrets management

This directory contains my secret files, encrypt by agenix:

- my wireguard configuration files, which is used by `wg-quick`
- github token, used by nix flakes to query and downloads flakes from github
  - without this, you may reach out github api rate limit.
- ssh key pairs for my homelab and other servers
- ...

## TODO

- a better way to manage all these secrets, is to used a separate private github repository to store all these secrets, and use it as a flakes input this this repo.
  - e.g. <https://github.com/xddxdd/nixos-config/blob/25ae3de/flake.nix#L82>

## Add or Update Secrets

This job is done by `agenix` CLI tool with the `./secrets.nix` file.

Pretend you want to add a new secret file `xxx.age`, then:

1. `cd` to this directory
1. edit `secrets.nix`, add a new entry for `xxx.age`, which defines the
   encryption keys and the secret file path, e.g.

```nix
# This file is not imported into your NixOS configuration. It is only used for the agenix CLI.
# agenix use the public keys defined in this file to encrypt the secrets.
# and users can decrypt the secrets by any of the corresponding private keys.

let
  # get user's ssh public key by command:
  #     cat ~/.ssh/id_ed25519.pub
  # if you do not have one, you can generate it by command:
  #     ssh-keygen -t ed25519
  ryan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJx3Sk20pLL1b2PPKZey2oTyioODrErq83xG78YpFBoj";
  users = [ ryan ];

  # get system's ssh public key by command:
  #    cat /etc/ssh/ssh_host_ed25519_key.pub
  ai = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICGeXNCazqiqxn8TmbCRjA+pLWrxwenn+CFhizBMP6en root@ai";
  systems = [ ai ];
in
{
  "./encrypt/xxx.age".publicKeys = users ++ systems;
}
```

2. create and edit the secret file `xxx.age` interactively by command:

```shell
agenix -e ./encrypt/xxx.age
```

3. or you can also encrypt an existing file to `xxx.age` by command:

```shell
cat /path/to/xxx | agenix -e ./encrypt/xxx.age
```

the agenix use `~/.ssh/id_ed25519.pub` or `~/.ssh/id_rsa.pub` as encrypt key by default, you need to pass `--identity /path/to/key` to use a custom `/path/to/key.pub` for enctypt.

## Deploy Secrets

This job is done by `nixos-rebuild` with the `./default.nix` file.

An nixos module exmaple(need to set agenix as flake inputs first...):

```nix
{ config, pkgs, agenix, ... }:

{
  imports = [
     agenix.nixosModules.default
  ];

  environment.systemPackages = [
    agenix.packages."${pkgs.system}".default
  ];

  age.secrets."xxx" = {
    # wether secrets are symlinked to age.secrets.<name>.path
    symlink = true;
    # target path for decrypted file
    path = "/etc/xxx/";
    # encrypted file path
    file = ./encrypt/xxx.age;
    mode = "0400";
    owner = "root";
    group = "root";
  };
}
```

`nixos-rebuild` will decrypt the secrets using the private keys defined by argument `age.identityPaths`,
And then symlink the secrets to the path defined by argument `age.secrets.<name>.path`, it defaults to `/etc/secrets`.

NOTE: `age.identityPaths` it defaults to `~/.ssh/id_ed25519` and `~/.ssh/id_rsa`, so you should put your decrypt keys there. if you're deploying to the same machine as you're encrypting from, it should work out of the box.
