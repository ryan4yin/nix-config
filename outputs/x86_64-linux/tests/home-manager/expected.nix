{
  myvars,
  lib,
}:
let
  username = myvars.username;
  hosts = [
    "ai-hyprland"
    "ruby"
    "k3s-prod-1-master-1"
  ];
in
lib.genAttrs hosts (_: "/home/${username}")
