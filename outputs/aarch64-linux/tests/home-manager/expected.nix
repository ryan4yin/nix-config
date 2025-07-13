{
  myvars,
  lib,
}: let
  username = myvars.username;
  hosts = [
    "shoukei-hyprland"
  ];
in
  lib.genAttrs hosts (_: "/home/${username}")
