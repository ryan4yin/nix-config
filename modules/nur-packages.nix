{ config, pkgs, ... }:

{
  nixpkgs.config.permittedInsecurePackages = [
    "electron-19.0.7"  # required by wechat-uos, and it's already EOL
  ];

  environment.systemPackages = with config.nur.repos.xddxdd; [
    # packages from nur-xddxdd
    wechat-uos
    qqmusic
  ];
}