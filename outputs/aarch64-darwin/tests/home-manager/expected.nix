{
  myvars,
  lib,
}: let
  username = myvars.username;
  hosts = [
    "fern"
  ];
in
  lib.genAttrs hosts (_: "/Users/${username}")
