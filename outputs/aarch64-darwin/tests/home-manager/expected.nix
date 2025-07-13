{
  myvars,
  lib,
}: let
  username = myvars.username;
  hosts = [
    "fern"
    "frieren"
  ];
in
  lib.genAttrs hosts (_: "/Users/${username}")
