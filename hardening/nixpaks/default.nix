{
  pkgs,
  pkgs-patched,
  nixpak,
  ...
}:
let
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
in
{
  # Add nixpaked Apps into nixpkgs, and reference them in home-manager or other nixos modules
  nixpkgs.overlays = [
    (_: super: {
      nixpaks = {
        qq = wrapper pkgs-patched ./qq.nix;
        qq-desktop-item = super.callPackage ./qq-desktop-item.nix { };

        wechat = wrapper super ./wechat.nix;
        wechat-desktop-item = super.callPackage ./wechat-desktop-item.nix { };

        firefox = wrapper super ./firefox.nix;
        firefox-desktop-item = super.callPackage ./firefox-desktop-item.nix { };
      };
    })
  ];
}
