{
  pkgs,
  lib,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      nixpaks.firefox
      nixpaks.google-chrome
      nixpaks.chromium
      nixpaks.brave-origin
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [ nixpaks.microsoft-edge ];
}
