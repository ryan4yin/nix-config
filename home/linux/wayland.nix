{ config, pkgs, ... }:

{
  imports = [
    ../common

    ./hyprland

    ./fcitx5
    ./desktop

    ./common/alacritty
    ./common/development.nix
    ./common/shell.nix
    ./common/ssh.nix
    ./common/system-tools.nix
    ./common/xdg.nix
  ];

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home = {
    username = "ryan";
    homeDirectory = "/home/ryan";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "22.11";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
