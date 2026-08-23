{ pkgs, ... }:
{
  home.packages =
    with pkgs;
    (lib.optionals pkgs.stdenv.hostPlatform.isx86_64 [
      # https://joplinapp.org/help/
      joplin # joplin-cli
      # joplin-desktop
    ]);
}
