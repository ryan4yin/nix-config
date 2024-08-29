{
  lib,
  pkgs,
  mkNixPak,
  nixpak-pkgs,
  ...
}:
mkNixPak {
  config = {sloth, ...}: {
    app.package = pkgs.prismlauncher;

    imports = [
      "${nixpak-pkgs}/pkgs/modules/gui-base.nix"
      "${nixpak-pkgs}/pkgs/modules/network.nix"
    ];

    bubblewrap = {
      bind.rw = [
        (sloth.concat' sloth.homeDir "/.local/share/PrismLauncher")
      ];
      sockets = {
        wayland = true;
        pipewire = true;
      };
    };
  };
}
