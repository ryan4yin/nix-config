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
  ...
}@args:
let
  # Shoukei (祥瓊, Shōkei)
  name = "shoukei";
  base-modules = {
    nixos-modules =
      (map mylib.relativeToRoot [
        # common
        "secrets/nixos.nix"
        "modules/nixos/desktop.nix"
        # host specific
        "hosts/12kingdoms-${name}"
        # nixos hardening
        # "hardening/profiles/default.nix"
        "hardening/nixpaks"
        "hardening/bwraps"
      ])
      ++ [
        {
          modules.desktop.fonts.enable = true;
          modules.desktop.wayland.enable = true;
          modules.secrets.desktop.enable = true;
          modules.secrets.preservation.enable = true;
          # not supported yet
          modules.desktop.gaming.enable = false;
        }
      ];
    home-modules = map mylib.relativeToRoot [
      "home/hosts/linux/12kingdoms-${name}.nix"
    ];
  };

  modules-niri = {
    nixos-modules = [
      { programs.niri.enable = true; }
    ]
    ++ base-modules.nixos-modules;
    home-modules = base-modules.home-modules;
  };
in
{
  nixosConfigurations = {
    "${name}-niri" = mylib.nixosSystem (modules-niri // args);
  };

  # generate iso image for hosts with desktop environment
  packages = {
    "${name}-niri" = inputs.self.nixosConfigurations."${name}-niri".config.formats.iso;
  };
}
