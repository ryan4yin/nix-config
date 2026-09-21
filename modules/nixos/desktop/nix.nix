{ config, ... }:
{
  nix.extraOptions = ''
    # decrypted secret: AI agents must not read it
    !include ${config.age.secrets.nix-access-tokens.path}
  '';
}
