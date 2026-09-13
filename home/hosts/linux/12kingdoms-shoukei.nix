{ config, ... }:
let
  hostName = "shoukei"; # Define your hostname.
  mkSymlink = config.lib.file.mkOutOfStoreSymlink;
in
{
  imports = [
    ../../linux/gui.nix
    ./12kingdoms-shoukei/wluma.nix
  ];

  programs.ssh.settings."github.com".IdentityFile = "${config.home.homeDirectory}/.ssh/${hostName}";

  modules.desktop.gaming.enable = false;
  modules.desktop.niri.enable = true;

  xdg.configFile."niri/niri-hardware.kdl".source =
    mkSymlink "${config.home.homeDirectory}/nix-config/hosts/12kingdoms-shoukei/niri-hardware.kdl";

  # The built-in laptop speakers are quiet, so boost above the -23 dB default.
  services.easyeffects.extraPresets."loudness-normalization".output."autogain#0".target = -12.0;
}
