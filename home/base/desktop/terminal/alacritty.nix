{
  pkgs,
  nur-ryan4yin,
  ...
}:
###########################################################
#
# Alacritty Configuration
#
# Useful Hot Keys for macOS:
#   1. Multi-Window: `command + N`
#   2. Increase Font Size: `command + =` | `command + +`
#   3. Decrease Font Size: `command + -` | `command + _`
#   4. Search Text: `command + F`
#   5. And Other common shortcuts such as Copy, Paste, Cursor Move, etc.
#
# Useful Hot Keys for Linux:
#   1. Increase Font Size: `ctrl + shift + =` | `ctrl + shift + +`
#   2. Decrease Font Size: `ctrl + shift + -` | `ctrl + shift + _`
#   3. Search Text: `ctrl + shift + N`
#   4. And Other common shortcuts such as Copy, Paste, Cursor Move, etc.
#
# Note: Alacritty do not have support for Tabs, and any graphic protocol.
#
###########################################################
{
  xdg.configFile."alacritty/theme_catppuccin.yml".source = "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-alacritty}/catppuccin-mocha.yml";
  programs.alacritty = {
    enable = true;
  };

  xdg.configFile."alacritty/alacritty.yml".text =
    ''
      import:
        # all alacritty themes can be found at
        #    https://github.com/alacritty/alacritty-theme
        - ~/.config/alacritty/theme_catppuccin.yml

      window:
        # Background opacity
        #
        # Window opacity as a floating point number from `0.0` to `1.0`.
        # The value `0.0` is completely transparent and `1.0` is opaque.
        opacity: 0.93

        # Startup Mode (changes require restart)
        #
        # Values for `startup_mode`:
        #   - Windowed
        #   - Maximized
        #   - Fullscreen
        #
        # Values for `startup_mode` (macOS only):
        #   - SimpleFullscreen
        startup_mode: Maximized

        # Allow terminal applications to change Alacritty's window title.
        dynamic_title: true

        # Make `Option` key behave as `Alt` (macOS only):
        #   - OnlyLeft
        #   - OnlyRight
        #   - Both
        #   - None (default)
        option_as_alt: Both

      scrolling:
        # Maximum number of lines in the scrollback buffer.
        # Specifying '0' will disable scrolling.
        history: 10000

        # Scrolling distance multiplier.
        #multiplier: 3

      # Font configuration
      font:
        # Normal (roman) font face
        bold:
          family: JetBrainsMono Nerd Font
        italic:
          family: JetBrainsMono Nerd Font
        normal:
          family: JetBrainsMono Nerd Font
        bold_italic:
          # Font family
          #
          # If the bold italic family is not specified, it will fall back to the
          # value specified for the normal font.
          family: JetBrainsMono Nerd Font
      shell:
        #  To resolve issues:
        #    1. https://github.com/ryan4yin/nix-config/issues/26
        #    2. https://github.com/ryan4yin/nix-config/issues/8
        #  Spawn a nushell in login mode via `bash`
        program: ${pkgs.bash}/bin/bash
        args:
          - --login
          - -c
          - 'nu --login --interactive'
    ''
    + (
      if pkgs.stdenv.isDarwin
      then ''
        # Point size
        size: 14
      ''
      else ''
        # holder identation
          # Point size
          size: 13
      ''
    );
}
