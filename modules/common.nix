{
  pkgs,
  lib,
  username,
  ...
}: {
  nix.settings = {
    # enable flakes globally
    experimental-features = ["nix-command" "flakes"];

    # given the users in this list the right to specify additional substituters via:
    #    1. `nixConfig.substituers` in `flake.nix`
    #    2. command line args `--options substituers http://xxx`
    trusted-users = [username];

    substituters = [
      # cache mirror located in China
      # status: https://mirror.sjtu.edu.cn/
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      # status: https://mirrors.ustc.edu.cn/status/
      # "https://mirrors.ustc.edu.cn/nix-channels/store"

      "https://cache.nixos.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    builders-use-substitutes = true;
  };

  # do garbage collection weekly to keep disk usage low
  nix.gc =
    {
      automatic = lib.mkDefault true;
      options = lib.mkDefault "--delete-older-than 7d";
    }
    // (
      if pkgs.stdenv.isLinux
      then {
        dates = lib.mkDefault "weekly";
      }
      else {
        # nix-darwin
        interval = {
          Hour = 24;
        };
      }
    );

  # Allow unfree packages
  nixpkgs.config.allowUnfree = lib.mkDefault false;
}
