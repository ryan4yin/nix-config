{ pkgs, ... }:

{
  # Squirrel Input Method
  home.file."Library/Rime" = {
    # my custom squirrel data (flypy input method)
    source = "${pkgs.flypy-squirrel}/share/rime-data";
    recursive = true;
  };
}
