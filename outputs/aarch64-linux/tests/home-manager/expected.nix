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
  hypridleScreenOffTracksActivity = true;
  hypridleLockTracksActivity = true;
  hypridleActivitySession = true;
  hypridleLockIgnoresInhibitors = true;
})
