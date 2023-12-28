{
  pkgs,
  nur-ryan4yin,
  ...
}: {
  # refer to https://codeberg.org/dnkl/foot/src/branch/master/foot.ini
  xdg.configFile."foot/foot.ini".text =
    (builtins.readFile "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-foot}/catppuccin-mocha.conf")
    + ''
      term=foot
      font=JetBrainsMono Nerd Font:size=13
      dpi-aware=yes
      shell=${pkgs.bash}/bin/bash --login -c 'nu --login --interactive'
    '';

  programs = {
    # a wayland only terminal emulator
    foot = {
      enable = true;
      # foot can also be run in a server mode. In this mode, one process hosts multiple windows.
      # All Wayland communication, VT parsing and rendering is done in the server process.
      # New windows are opened by running footclient, which remains running until the terminal window is closed.
      #
      # Advantages to run foot in server mode including reduced memory footprint and startup time.
      # The downside is a performance penalty. If one window is very busy with, for example, producing output,
      # then other windows will suffer. Also, should the server process crash, all windows will be gone.
      server.enable = false;
    };

    # source code: https://github.com/nix-community/home-manager/blob/master/modules/programs/chromium.nix
    google-chrome = {
      enable = true;

      commandLineArgs = [
        # make it use GTK_IM_MODULE if it runs with Gtk4, so fcitx5 can work with it.
        # (only supported by chromium/chrome at this time, not electron)
        "--gtk-version=4"
        "--enable-features=UseOzonePlatform"
        "--ozone-platform=wayland"
        # make it use text-input-v1, which works for kwin 5.27 and weston
        "--enable-wayland-ime"

        # enable hardware acceleration - vulkan api
        # "--enable-features=Vulkan"
      ];
    };

    firefox = {
      enable = true;
      enableGnomeExtensions = false;
      package = pkgs.firefox-wayland; # firefox with wayland support
    };
  };
}
