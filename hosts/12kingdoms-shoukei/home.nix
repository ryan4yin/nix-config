{ config, ... }:
let
  hostName = "shoukei"; # Define your hostname.
in
{
  modules.desktop.hyprland = {
    nvidia = false;
    settings.source = [
      "${config.home.homeDirectory}/nix-config/hosts/12kingdoms-shoukei/hypr-hardware.conf"
    ];
  };

  programs.ssh.matchBlocks."github.com".identityFile =
    "${config.home.homeDirectory}/.ssh/${hostName}";
}
