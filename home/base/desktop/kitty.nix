{ ... }: {
  programs.kitty = {
    enable = true;
    theme = "Catppuccin-Mocha";
    # darwinLaunchOptions = {};
    font = {
      name = " JetBrainsMono Nerd Font";
    };

    settings = {
      background_opacity = "0.92";
      macos_option_as_alt = true;  # Option key acts as Alt on macOS
      scrollback_lines = 10000;
      enable_audio_bell = false;
    };
  };
}
