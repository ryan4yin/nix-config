{ config, pkgs, ... }:

{
  # this params has problem with home-manager,
  # so defined as NixOS Module here.
  nixpkgs.config.permittedInsecurePackages = [
    "electron-19.0.7"  # required by wechat-uos, and it's already EOL
    "openssl-1.1.1t"   # OpenSSL 1.1 is reaching its end of life on 2023/09/11
  ];

  environment.systemPackages = with config.nur.repos.xddxdd; [
    # packages from nur-xddxdd
    wechat-uos
  ];

  # flatpack is recommended to install other apps such as netease-cloud-music/qqmusic/...
}