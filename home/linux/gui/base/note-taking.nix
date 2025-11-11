{ pkgs, ... }:
{
  home.packages =
    with pkgs;
    (lib.optionals pkgs.stdenv.isx86_64 [
      # https://joplinapp.org/help/
      joplin # joplin-cli
      # joplin-desktop
    ]);
}
