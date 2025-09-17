{
  # NOTE: the args not used in this file CAN NOT be removed!
  # because haumea pass argument lazily,
  # and these arguments are used in the functions like `mylib.nixosSystem`, `mylib.colmenaSystem`, etc.
  inputs,
  lib,
  myvars,
  mylib,
  system,
  genSpecialArgs,
  niri,
  ...
}@args:
let
  # 星野 アイ, Hoshino Ai
  name = "ai";
  base-modules = {
    nixos-modules =
      (map mylib.relativeToRoot [
        # common
        "secrets/nixos.nix"
        "modules/nixos/desktop.nix"
        # host specific
        "hosts/idols-${name}"
        # nixos hardening
        # "hardening/profiles/default.nix"
        "hardening/nixpaks"
        "hardening/bwraps"
      ])
      ++ [
        inputs.niri.nixosModules.niri
        {
          modules.desktop.fonts.enable = true;
          modules.desktop.wayland.enable = true;
          modules.secrets.desktop.enable = true;
          modules.secrets.preservation.enable = true;
          modules.desktop.gaming.enable = true;
        }
      ];
    home-modules =
      (map mylib.relativeToRoot [
        # common
        "home/linux/gui.nix"
        # host specific
        "hosts/idols-${name}/home.nix"
      ])
      ++ [
        {
          modules.desktop.gaming.enable = true;
        }
      ];
  };

  modules-hyprland = {
    nixos-modules = [
    ]
    ++ base-modules.nixos-modules;
    home-modules = [
      { modules.desktop.hyprland.enable = true; }
    ]
    ++ base-modules.home-modules;
  };

  modules-niri = {
    nixos-modules = [
      { programs.niri.enable = true; }
    ]
    ++ base-modules.nixos-modules;
    home-modules = [
      { modules.desktop.niri.enable = true; }
    ]
    ++ base-modules.home-modules;
  };
in
{
  nixosConfigurations = {
    # host with hyprland compositor
    "${name}-hyprland" = mylib.nixosSystem (modules-hyprland // args);
    "${name}-niri" = mylib.nixosSystem (modules-niri // args);
  };

  # generate iso image for hosts with desktop environment
  packages = {
    "${name}-hyprland" = inputs.self.nixosConfigurations."${name}-hyprland".config.formats.iso;
    "${name}-niri" = inputs.self.nixosConfigurations."${name}-niri".config.formats.iso;
  };
}
