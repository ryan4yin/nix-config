{ lib, ... }:
let
  fontSize = 15;
in
{
  programs.ghostty.settings.font-size = lib.mkForce fontSize;
  programs.kitty.font.size = lib.mkForce fontSize;
}
