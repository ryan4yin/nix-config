{
  pkgs,
  nixpak,
  ...
}: let
  mkNixPak = nixpak.lib.nixpak {
    inherit (pkgs) lib;
    inherit pkgs;
  };
in {
  _module.args = {inherit mkNixPak;};
}
