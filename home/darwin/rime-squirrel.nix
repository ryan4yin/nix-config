{
  config,
  lib,
  pkgs,
  ...
}: {
  # remove existing rime data (squirrel)
  home.activation.removeExistingRimeData = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    rm -rf "${config.home.homeDirectory}/Library/Rime/build/flypy.prism.bin"
  '';

  # Squirrel Input Method
  home.file."Library/Rime" = {
    # my custom squirrel data (flypy input method)
    source = "${pkgs.flypy-squirrel}/share/rime-data";
    recursive = true;
  };
}
