{ pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
  };

  xdg.configFile."alacritty/alacritty.yml".text = ''
    import:
      # all alacritty themes can be found at
      #    https://github.com/alacritty/alacritty-theme
      - ~/.config/alacritty/theme_catppuccino.yml
    
    window:
      # Background opacity
      #
      # Window opacity as a floating point number from `0.0` to `1.0`.
      # The value `0.0` is completely transparent and `1.0` is opaque.
      opacity: 0.90
    
      # Startup Mode (changes require restart)
      #
      # Values for `startup_mode`:
      #   - Windowed
      #   - Maximized
      #   - Fullscreen
      #
      # Values for `startup_mode` (macOS only):
      #   - SimpleFullscreen
      startup_mode: Windowed
    
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
  '' + (if pkgs.stdenv.isDarwin then ''
      # Point size
      size: 14
    shell:  # force nushell as default shell on macOS
     program:  /run/current-system/sw/bin/nu
  '' else ''
      # Point size
      size: 13
  '');


  xdg.configFile."alacritty/theme_catppuccino.yml".source = ./theme_catppuccino.yml;
}
