{ myvars, pkgs, ... }:
{
  users.users.${myvars.username}.shell = pkgs.nushell;
  environment.shells = [ pkgs.nushell ];
}
