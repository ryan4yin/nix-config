{ config, ... }:
{
  # 1. make `npm install -g <pkg>` happey
  # 2. set min-release-age for security
  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm
    min-release-age=7
  '';
}
