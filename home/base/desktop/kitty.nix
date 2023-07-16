{ lib, pkgs, ... }: {
  programs.kitty = {
    enable = true;
    theme = "Catppuccin-Mocha";
    font = {
      name = "JetBrainsMono Nerd Font";
      # use different font size on macOS
      size = if pkgs.stdenv.isDarwin then 14 else 13;
    };

    settings = {
      background_opacity = "0.95";
      macos_option_as_alt = true;  # Option key acts as Alt on macOS
      scrollback_lines = 10000;
      enable_audio_bell = false;
    } // (if pkgs.stdenv.isDarwin then {
      # macOS specific settings, force kitty to use nushell as default shell
      shell = "/run/current-system/sw/bin/nu";
    } else {});
  };
}
