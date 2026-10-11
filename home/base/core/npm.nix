{ config, ... }:
{
  # make `npm install -g <pkg>` happey
  # npm - set min-release-age(in days) for supply-chain security
  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm
    min-release-age=2
  '';

  # pnpm - same supply-chain policy; minimumReleaseAge is in minutes (2880 = 2 days)
  xdg.configFile."pnpm/config.yaml".text = ''
    minimumReleaseAge: 2880
  '';
}
