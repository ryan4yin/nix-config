{
  nixpkgs.overlays = [
    (_: super: {
      bwraps = {
        wechat = super.callPackage ./wechat.nix { };
      };
    })
  ];
}
