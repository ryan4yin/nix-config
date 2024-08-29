{
  pkgs,
  nixpak,
  ...
}: let
  mkNixPak = nixpak.lib.nixpak {
    inherit (pkgs) lib;
    inherit pkgs;
  };
in {
  _module.args = {inherit mkNixPak;};

  nixpkgs.overlays = [
    (_: super: {
      nixpaks = {
        qq = super.callPackage ./qq.nix;
        wechat = super.callPackage ./wechat.nix;
        firefox = super.callPackage ./firefox.nix;
      };
    })
  ];
}
