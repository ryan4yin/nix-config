{nuenv, ...} @ args: {
  nixpkgs.overlays =
    [
      nuenv.overlays.default
    ]
    ++ (import ../../overlays args);
}
