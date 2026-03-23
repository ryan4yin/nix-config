{ config, ... }:
let
  mkSymlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  imports = [ ../../linux/gui.nix ];

  programs.ssh.matchBlocks."github.com".identityFile = "${config.home.homeDirectory}/.ssh/idols-ai";

  modules.desktop.gaming.enable = true;
  modules.desktop.niri.enable = true;
  modules.desktop.nvidia.enable = true;

  xdg.configFile."niri/niri-hardware.kdl".source =
    mkSymlink "${config.home.homeDirectory}/nix-config/hosts/idols-ai/niri-hardware.kdl";
}
