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
  # Add nixpaked Apps into nixpkgs, and reference them in home-manager or other nixos modules
  nixpkgs.overlays = [
    (_: super: {
      nixpaks = {
        qq = super.callPackage ./qq.nix callArgs;
        wechat = super.callPackage ./wechat.nix callArgs;
        firefox = super.callPackage ./firefox.nix callArgs;
        netease-cloud-music-gtk = super.callPackage ./netease-cloud-music-gtk.nix callArgs;
        prismlauncher = super.callPackage ./prismlauncher.nix callArgs;
      };
    })
  ];
}
