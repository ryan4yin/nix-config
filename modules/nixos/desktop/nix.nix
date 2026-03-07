{ config, ... }:
{
  nix.extraOptions = ''
    !include ${config.age.secrets.nix-access-tokens.path}
  '';
}
