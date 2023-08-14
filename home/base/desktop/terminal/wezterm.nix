{
  lib,
  pkgs,
  pkgs-unstable,
  catppuccin-wezterm,
  ...
}:
###########################################################
#
# Wezterm Configuration
#
###########################################################
{
  # wezterm has catppuccin theme built-in,
  # it's not necessary to install it separately.
  # xdg.configFile."wezterm/colors".source = "${catppuccin-wezterm}/dist";

  programs.wezterm = {
    enable = true;
    package = pkgs-unstable.wezterm;

    extraConfig = 
      let
        fontsize = if pkgs.stdenv.isDarwin then "14.0" else "13.0";
      in
      ''
        -- Pull in the wezterm API
        local wezterm = require 'wezterm'
        
        -- This table will hold the configuration.
        local config = {}
        
        -- In newer versions of wezterm, use the config_builder which will
        -- help provide clearer error messages
        if wezterm.config_builder then
          config = wezterm.config_builder()
        end
        
        -- This is where you actually apply your config choices
        config.color_scheme = "Catppuccin Mocha"
        config.font = wezterm.font("JetBrains Mono")
        config.hide_tab_bar_if_only_one_tab = true
        config.scrollback_lines = 10000
        config.enable_scroll_bar = true

        config.font_size = ${fontsize}
      '' + (if pkgs.stdenv.isDarwin then ''
        -- Spawn a fish shell in login mod
        config.default_prog = { '/run/current-system/sw/bin/nu', '-l' }
      '' else "") + ''
        return config
      '';
  };
}
