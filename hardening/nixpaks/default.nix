{
  pkgs,
  pkgs-master,
  nixpak,
  ...
}:
let
  callArgs = {
    mkNixPak = nixpak.lib.nixpak {
      inherit (pkgs) lib;
      inherit pkgs;
    };
  };
  wrapper = _pkgs: path: (_pkgs.callPackage path callArgs);
in
{
  # Add nixpaked Apps into nixpkgs, and reference them in home-manager or other nixos modules
  nixpkgs.overlays = [
    (_: super: {
      nixpaks = {
        qq = wrapper pkgs-master ./qq.nix;
        telegram-desktop = wrapper super ./telegram-desktop.nix;
        firefox = wrapper super ./firefox.nix;
      };
    })
  ];
}
