{
  myvars,
  lib,
}:
let
  username = myvars.username;
  hosts = [
    "shoukei-niri"
  ];
in
lib.genAttrs hosts (_: "/home/${username}")
