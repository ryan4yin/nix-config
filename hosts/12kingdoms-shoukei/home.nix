{ config, ... }:
let
  hostName = "shoukei"; # Define your hostname.
  mkSymlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  programs.ssh.matchBlocks."github.com".identityFile =
    "${config.home.homeDirectory}/.ssh/${hostName}";

  modules.desktop.nvidia.enable = false;
  modules.desktop.hyprland.settings.source = [
    "${config.home.homeDirectory}/nix-config/hosts/12kingdoms-shoukei/hypr-hardware.conf"
  ];

  xdg.configFile."niri/niri-hardware.kdl".source =
    mkSymlink "${config.home.homeDirectory}/nix-config/hosts/12kingdoms-shoukei/niri-hardware.kdl";
}
