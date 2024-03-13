{
  myvars,
  lib,
}: let
  username = myvars.username;
  hosts = [
    "harmonica"
  ];
in
  lib.genAttrs hosts (_: "/Users/${username}")
