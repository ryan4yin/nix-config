{ config, ... }:
{
  # make `npm install -g <pkg>` happey
  # npm - set min-release-age(in days) for supply-chain security
  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm
    min-release-age=2
  '';

  # npm - set min release age (in minutes) for supply-chain security
  xdg.configFile."pnpm/config.yaml".text = ''
    minimumReleaseAge: 2880
  '';
}
