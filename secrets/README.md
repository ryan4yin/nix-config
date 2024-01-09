
# Secrets Management

All my secrets are safely encrypted via agenix, and stored in a separate private GitHub repository and referenced as a flake input in this flake.

In this way, all secrets is still encrypted when transmitted over the network and written to `/nix/store`,
they are decrypted only when they are finally used.

In addition, we further improve the security of secrets files by storing them in a separate private repository.

This directory contains this README.md, and a `nixos.nix`/`darwin.nix` that used to decrypt all my secrets via agenix, and then I can use them in this flake.

## Adding or Updating Secrets

> All the operations in this section should be performed in my private repository: `nix-secrets`.

This task is accomplished using the [agenix](https://github.com/ryantm/agenix) CLI tool with the `./secrets.nix` file, so you need to have it installed first:

To use agenix temporarily, run:

```bash
nix shell nixpkgs#agenix
```

Suppose you want to add a new secret file `xxx.age`. Follow these steps:

1. Navigate to your private `nix-secrets` repository.
2. Edit `secrets.nix` and add a new entry for `xxx.age`, defining the encryption keys and the secret file path, for example:

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
  "./xxx.age".publicKeys = users ++ systems;
}
```

3. Create and edit the secret file `xxx.age` interactively using the following command:

```shell
agenix -e ./xxx.age
```

Alternatively, you can encrypt an existing file to `xxx.age` using the following command:

```shell
cat /path/to/xxx | agenix -e ./xxx.age
```

`agenix` will encrypt the file with all the public keys we defined in `secrets.nix`, 
so all the users and systems defined in `secrets.nix` can decrypt it with their private keys.

## Deploying Secrets

> All the operations in this section should be performed in this repository.

First, add your own private `nix-secrets` repository and `agenix` as a flake input, and pass them to sub modules via `specialArgs`:

```nix
{
  inputs = {
    # ......

    # secrets management, lock with git commit at 2023/5/15
    agenix.url = "github:ryantm/agenix/db5637d10f797bb251b94ef9040b237f4702cde3";

    # my private secrets, it's a private repository, you need to replace it with your own.
    mysecrets = { url = "github:ryan4yin/nix-secrets"; flake = false; };
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
          ./secrets/default.nix
        ];
      };
    };
  };
}
```

Then, create `./secrets/default.nix` with the following content:

```nix
# import & decrypt secrets in `mysecrets` in this module
{ config, pkgs, agenix, mysecrets, ... }:

{
  imports = [
     agenix.nixosModules.default
  ];

  # if you changed this key, you need to regenerate all encrypt files from the decrypt contents!
  age.identityPaths = [ 
    "/home/ryan/.ssh/juliet-age"
  ];

  age.secrets."xxx" = {
    # whether secrets are symlinked to age.secrets.<name>.path
    symlink = true;
    # target path for decrypted file
    path = "/etc/xxx/";
    # encrypted file path
    file =  "${mysecrets}/xxx.age";  # refer to ./xxx.age located in `mysecrets` repo
    mode = "0400";
    owner = "root";
    group = "root";
  };
}
```

From now on, every time you run `nixos-rebuild switch`, it will decrypt the secrets using the private keys defined in `age.identityPaths`. 
It will then symlink the secrets to the path defined by the `age.secrets.<name>.path` argument, which defaults to `/etc/secrets`.

NOTE: By default, `age.identityPaths` is set to `~/.ssh/id_ed25519` and `~/.ssh/id_rsa`, 
so make sure to place your decryption keys there.
If you're deploying to the same machine from which you encrypted the secrets, it should work out of the box.

## Other Replacements

- [ragenix](https://github.com/yaxitech/ragenix): A Rust reimplementation of agenix.
  - agenix is mainly written in bash, and it's error message is quite obscure, a little typo may cause some errors no one can understand.
  - with a type-safe language like Rust, we can get a better error message and less bugs.

