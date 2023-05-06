{
  pkgs,
  config,
  nixos-cn,
  ...
}:
{

  home.packages = with nixos-cn; [
    qq
    wechat-uos
    netease-cloud-music
  ];

  programs = {
    mpv = {
      enable = true;
      defaultProfiles = ["gpu-hq"];
      scripts = [pkgs.mpvScripts.mpris];
    };

    obs-studio.enable = true;
  };

  services = {
    playerctld.enable = true;
  };
}