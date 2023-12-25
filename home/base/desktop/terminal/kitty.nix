{
  lib,
  pkgs,
  ...
}:
###########################################################
#
# Kitty Configuration
#
# Useful Hot Keys for macOS:
#   1. New Tab: `command + t`
#   2. Close Tab: `command + w`
#   3. Switch Tab: `command + shift + [` | `command + shift + ]`
#   4. Increase Font Size: `command + =` | `command + +`
#   5. Decrease Font Size: `command + -` | `command + _`
#   6. And Other common shortcuts such as Copy, Paste, Cursor Move, etc.
#   7. Search/Select in the current window(show_scrollback): `ctrl + shift + f`
#          This will open a pager, it's defined by `scrollback_pager`, default is `less`
#          https://sw.kovidgoyal.net/kitty/overview/#the-scrollback-buffer
#
# Useful Hot Keys for Linux:
#   1. New Tab: `ctrl + shift + t`
#   2. Close Tab: `ctrl + shift + q`
#   3. Switch Tab: `ctrl + shift + right` | `ctrl + shift + left`
#   4. Increase Font Size: `ctrl + shift + =` | `ctrl + shift + +`
#   5. Decrease Font Size: `ctrl + shift + -` | `ctrl + shift + _`
#   6. And Other common shortcuts such as Copy, Paste, Cursor Move, etc.
#
###########################################################
{
  programs.kitty = {
    enable = true;
    # kitty has catppuccin theme built-in,
    # all the built-in themes are packaged into an extra package named `kitty-themes`
    # and it's installed by home-manager if `theme` is specified.
    theme = "Catppuccin-Mocha";
    font = {
      name = "JetBrainsMono Nerd Font";
      # use different font size on macOS
      size =
        if pkgs.stdenv.isDarwin
        then 14
        else 13;
    };

    # consistent with wezterm
    keybindings = {
      "ctrl+shift+m" = "toggle_maximized";
      "ctrl+shift+f" = "show_scrollback"; # search in the current window
      "cmd+f" = "show_scrollback";
      # Switch to tab 1-8(consistent with wezterm)
      "ctrl+shift+1" = "goto_tab 1";
      "ctrl+shift+2" = "goto_tab 2";
      "ctrl+shift+3" = "goto_tab 3";
      "ctrl+shift+4" = "goto_tab 4";
      "ctrl+shift+5" = "goto_tab 5";
      "ctrl+shift+6" = "goto_tab 6";
      "ctrl+shift+7" = "goto_tab 7";
      "ctrl+shift+8" = "goto_tab 8";
    };

    settings = {
      background_opacity = "0.93";
      macos_option_as_alt = true; # Option key acts as Alt on macOS
      scrollback_lines = 10000;
      enable_audio_bell = false;
      tab_bar_edge = "top"; # tab bar on top
      #  To resolve issues:
      #    1. https://github.com/ryan4yin/nix-config/issues/26
      #    2. https://github.com/ryan4yin/nix-config/issues/8
      #  Spawn a nushell in login mode via `bash`
      shell = "${pkgs.bash}/bin/bash --login -c 'nu --login --interactive'";
      # for selecting/searching in the current window
      # https://github.com/kovidgoyal/kitty/issues/719
      scrollback_pager = ''$SHELL -c 'nvim -u NONE -R -M -u ${./kitty_pager.lua} -c "lua kitty_pager(INPUT_LINE_NUMBER, CURSOR_LINE, CURSOR_COLUMN)" -' '';
      # for active tab
      active_tab_title_template = "{fmt.fg.green}{bell_symbol}{activity_symbol}{fmt.fg.tab}{index}:{title}";
      # for inactive tab
      tab_title_template = "{fmt.fg.red}{bell_symbol}{activity_symbol}{fmt.fg.tab}{index}:{title}";
    };

    # macOS specific settings
    darwinLaunchOptions = ["--start-as=maximized"];
  };
}
