{
  nixpkgs,
  home-manager,
  nixos-generators,
  system,
  specialArgs,
  nixos-modules,
  home-module,
}: let
  inherit (specialArgs) username;
in
  nixpkgs.lib.nixosSystem {
    inherit system specialArgs;
    modules =
      nixos-modules
      ++ [
        {
          # make `nix run nixpkgs#nixpkgs` use the same nixpkgs as the one used by this flake.
          nix.registry.nixpkgs.flake = nixpkgs;
          nix.channel.enable = false; # remove nix-channel related tools & configs, we use flakes instead.
          
          # but NIX_PATH is still used by many useful tools, so we set it to the same value as the one used by this flake.
          # Make `nix repl '<nixpkgs>'` use the same nixpkgs as the one used by this flake.
          environment.etc."nix/inputs/nixpkgs".source = "${nixpkgs}";
          nix.settings.nix-path = nixpkgs.lib.mkForce "nixpkgs=/etc/nix/inputs/nixpkgs";
          environment.sessionVariables.NIX_PATH = nixpkgs.lib.mkForce "nixpkgs=/etc/nix/inputs/nixpkgs";
        }

        nixos-generators.nixosModules.all-formats
        {
          # formatConfigs.iso = {config, ...}: {};
          formatConfigs.proxmox = {config, ...}: {
            # custom proxmox's image name
            proxmox.qemuConf.name = "${config.networking.hostName}-nixos-${config.system.nixos.label}";
          };
        }

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;

          home-manager.extraSpecialArgs = specialArgs;
          home-manager.users."${username}" = home-module;
        }
      ];
  }
