# https://github.com/fufexan/dotfiles/blob/483680e/system/programs/steam.nix
{pkgs, ...}: {
  # https://wiki.archlinux.org/title/steam
  programs.steam = {
    # steam will be installed into ~/.local/share/Steam
    # the games will be installed into ~/.local/share/Steam/steamapps/common
    enable = true;

    # fix gamescope inside steam
    package = pkgs.steam.override {
      extraPkgs = pkgs:
        with pkgs; [
          keyutils
          libkrb5
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
        ];
    };
  };

  fonts.packages = with pkgs; [
    wqy_zenhei # Need by steam for Chinese
  ];
}
