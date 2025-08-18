{
  myvars,
  lib,
}:
let
  username = myvars.username;
  hosts = [
    "shoukei-hyprland"
    "shoukei-niri"
  ];
in
lib.genAttrs hosts (_: "/home/${username}")
