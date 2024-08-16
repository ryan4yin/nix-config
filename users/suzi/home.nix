{pkgs, ...}: {
  ##################################################################################################################
  #
  # All Suzi's Home Manager Configuration
  #
  ##################################################################################################################

  imports = [
    ../../home/core.nix

    ./fcitx5
    ./i3
    ./programs
    ./rofi
    ./shell
  ];

  programs.git = {
    userName = "Suzi";
    userEmail = "suzi@writefor.fun";
  };
}
