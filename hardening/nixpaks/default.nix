{
  pkgs,
  nixpak,
  ...
}: let
  callArgs = {
    mkNixPak = nixpak.lib.nixpak {
      inherit (pkgs) lib;
      inherit pkgs;
    };
    safeBind = sloth: realdir: mapdir: [
      (sloth.mkdir (sloth.concat' sloth.appDataDir realdir))
      (sloth.concat' sloth.homeDir mapdir)
    ];
  };
  wrapper = _pkgs: path: (_pkgs.callPackage path callArgs).config.script;
in {
  # Add nixpaked Apps into nixpkgs, and reference them in home-manager or other nixos modules
  nixpkgs.overlays = [
    (_: super: {
      nixpaks = {
        qq = wrapper super ./qq.nix;
        qq-desktop-item = super.callPackage ./qq-desktop-item.nix {};

        wechat-uos = wrapper super ./wechat-uos.nix;
        wechat-uos-desktop-item = super.callPackage ./wechat-uos-desktop-item.nix {};

        firefox = wrapper super ./firefox.nix;
        firefox-desktop-item = super.callPackage ./firefox-desktop-item.nix {};
      };
    })
  ];
}
