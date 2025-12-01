{ lib, ... }:
let
  fontSize = 15;
in
{
  programs.alacritty.settings.font.size = lib.mkForce fontSize;
  programs.ghostty.settings.font-size = lib.mkForce fontSize;
  programs.kitty.font.size = lib.mkForce fontSize;
}
