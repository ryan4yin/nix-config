{ pkgs-master, ... }:
{
  programs.clash-verge = {
    enable = true;
    package = pkgs-master.clash-verge-rev;
    autoStart = false;
    serviceMode = true;
    tunMode = true;
  };
}
