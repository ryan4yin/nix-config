{
  pkgs,
  ...
}:
###########################################################
#
# Kitty Configuration
#
# TUIOS provides tabs, panes, scrollback and copy mode, so kitty
# only needs a font, transparency and the kitty graphics protocol
# (built in).
#
###########################################################
{
  programs.kitty = {
    enable = true;
    font = {
      name = "Maple Mono NF CN";
      size = 13; # macOS overrides this in home/darwin/terminal.nix
    };

    settings = {
      # no title bar / window title ("titlebar-and-corners" is macOS-only)
      hide_window_decorations =
        if pkgs.stdenv.hostPlatform.isDarwin then "titlebar-and-corners" else "yes";
      macos_show_window_title_in = "none";

      # transparency
      background_opacity = "0.85";

      macos_option_as_alt = true; # Option key acts as Alt on macOS
      enable_audio_bell = false;

      #  To resolve issues:
      #    1. https://github.com/ryan4yin/nix-config/issues/26
      #    2. https://github.com/ryan4yin/nix-config/issues/8
      #  Spawn a nushell in login mode via `bash`
      shell = "${pkgs.bash}/bin/bash --login -c 'nu --login --interactive'";
    };

    # macOS specific settings
    darwinLaunchOptions = [ "--start-as=fullscreen" ];
  };
}
