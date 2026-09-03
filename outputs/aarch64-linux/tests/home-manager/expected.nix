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
lib.genAttrs hosts (_: {
  homeDirectory = "/home/${username}";
  hypridleScreenOffIgnoresInhibitors = true;
  hypridleScreenOffSkipsPlayingMedia = true;
  hypridleLockIgnoresInhibitors = true;
})
