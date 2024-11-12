{
  pkgs,
  pkgs-unstable,
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
  programs.alacritty = {
    enable = true;
    package = pkgs-unstable.alacritty;
    # https://alacritty.org/config-alacritty.html
    settings = {
      general.import = [
        ./catppuccin-mocha.toml
      ];
      window = {
        opacity = 0.93;
        startup_mode = "Maximized"; # Maximized window
        dynamic_title = true;
        option_as_alt = "Both"; # Option key acts as Alt on macOS
      };
      scrolling = {
        history = 10000;
      };
      font = {
        bold = {family = "JetBrainsMono Nerd Font";};
        italic = {family = "JetBrainsMono Nerd Font";};
        normal = {family = "JetBrainsMono Nerd Font";};
        bold_italic = {family = "JetBrainsMono Nerd Font";};
        size =
          if pkgs.stdenv.isDarwin
          then 14
          else 13;
      };
      terminal = {
        # Spawn a nushell in login mode via `bash`
        shell = {
          program = "${pkgs.bash}/bin/bash";
          args = ["--login" "-c" "nu --login --interactive"];
        };
        # Controls the ability to write to the system clipboard with the OSC 52 escape sequence.
        # It's used by zellij to copy text to the system clipboard.
        osc52 = "CopyPaste";
      };
    };
  };
}
