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
in {
  nixpkgs.overlays = [
    (_: super: {
      nixpaks = {
        qq = super.callPackage ./qq.nix callArgs;
        wechat = super.callPackage ./wechat.nix callArgs;
        firefox = super.callPackage ./firefox.nix callArgs;
      };
    })
  ];
}
