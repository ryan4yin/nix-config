{
  myvars,
  lib,
}:
let
  username = myvars.username;
  hosts = [
    "ai-niri"
    "ruby"
  ];
in
lib.genAttrs hosts (_: "/home/${username}")
