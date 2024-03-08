{
  pkgs,
  config,
  lib,
  myvars,
  pkgs-unstable,
  ...
}: let
  homeDir = config.users.users."${myvars.username}".home;
in {
  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/os-specific/darwin/yabai/default.nix
  services.yabai = {
    enable = true;
    # temporary workaround for https://github.com/ryan4yin/nix-config/issues/51
    package = pkgs-unstable.yabai.overrideAttrs (oldAttrs: rec {
      version = "6.0.7";
      src =
        if pkgs.stdenv.isAarch64
        then
          (pkgs.fetchzip {
            url = "https://github.com/koekeishiya/yabai/releases/download/v${version}/yabai-v${version}.tar.gz";
            hash = "sha256-hZMBXSCiTlx/37jt2yLquCQ8AZ2LS3heIFPKolLub1c=";
          })
        else
          (pkgs.fetchFromGitHub {
            owner = "koekeishiya";
            repo = "yabai";
            rev = "v${version}";
            hash = "sha256-vWL2KA+Rhj78I2J1kGItJK+OdvhVo1ts0NoOHIK65Hg=";
          });
    });

    # Whether to enable yabai's scripting-addition.
    # SIP must be disabled for this to work.
    # https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection
    enableScriptingAddition = true;
    # config = {};
    extraConfig = builtins.readFile ./yabairc;
  };

  # custom log path for debugging
  launchd.user.agents.yabai.serviceConfig = {
    StandardErrorPath = "${homeDir}/Library/Logs/yabai.stderr.log";
    StandardOutPath = "${homeDir}/Library/Logs/yabai.stdout.log";
  };
}
