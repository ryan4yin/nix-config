{ lib, pkgs, ... }: {
  programs.kitty = {
    enable = true;
    theme = "Catppuccin-Mocha";
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 14;
    };

    settings = {
      background_opacity = "0.95";
      macos_option_as_alt = true;  # Option key acts as Alt on macOS
      scrollback_lines = 10000;
      enable_audio_bell = false;
    } // lib.mkIf pkgs.stdenv.isDarwin {
      # macOS specific settings, force kitty to use nushell as default shell
      shell = "/run/current-system/sw/bin/nu";
    };
  };
}
