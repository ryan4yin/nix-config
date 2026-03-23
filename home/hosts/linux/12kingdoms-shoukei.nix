{ config, ... }:
let
  hostName = "shoukei"; # Define your hostname.
  mkSymlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  imports = [ ../../linux/gui.nix ];

  programs.ssh.matchBlocks."github.com".identityFile =
    "${config.home.homeDirectory}/.ssh/${hostName}";

  modules.desktop.gaming.enable = false;
  modules.desktop.niri.enable = true;
  modules.desktop.nvidia.enable = false;

  xdg.configFile."niri/niri-hardware.kdl".source =
    mkSymlink "${config.home.homeDirectory}/nix-config/hosts/12kingdoms-shoukei/niri-hardware.kdl";
}
