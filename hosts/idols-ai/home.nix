{ config, ... }:
let
  mkSymlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  programs.ssh.matchBlocks."github.com".identityFile = "${config.home.homeDirectory}/.ssh/idols-ai";

  modules.desktop.nvidia.enable = true;

  modules.desktop.hyprland.settings.source = [
    "${config.home.homeDirectory}/nix-config/hosts/idols-ai/hypr-hardware.conf"
  ];
  xdg.configFile."niri/niri-hardware.kdl".source =
    mkSymlink "${config.home.homeDirectory}/nix-config/hosts/idols-ai/niri-hardware.kdl";
}
