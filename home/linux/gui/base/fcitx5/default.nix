{
  config,
  pkgs,
  ...
}:
{
  catppuccin.fcitx5.enable = false;
  xdg.configFile = {
    "fcitx5/profile" = {
      source = ./profile;
      # every time fcitx5 switch input method, it will modify ~/.config/fcitx5/profile,
      # so we need to force replace it in every rebuild to avoid file conflict.
      force = true;
    };
    # `AltTriggerKeys` (the "temporarily toggle input method" hotkey) would
    # toggle on left Shift, its default being Shift_L. Keep it empty so only
    # right Shift (through Rime) and Ctrl+Space switch CN/EN. force = true
    # because fcitx5 rewrites this file at runtime, like `profile`.
    "fcitx5/config" = {
      text = ''
        [Hotkey/AltTriggerKeys]
      '';
      force = true;
    };
    "mozc/config1.db".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-config/home/linux/gui/base/fcitx5/mozc-config1.db";
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.waylandFrontend = true;
    fcitx5.addons = with pkgs; [
      qt6Packages.fcitx5-configtool # GUI for fcitx5
      fcitx5-gtk # gtk im module

      # Chinese: the flypy (小鹤音形) fcitx5-rime addon is wired in
      # home/base/gui/rime/default.nix, which is also where the rime-data-flypy
      # package is resolved. fcitx5-chinese-addons is not used.

      # Japanese
      # ctrl-i / F7 - convert to takakana
      # ctrl-u / F6 - convert to hiragana
      fcitx5-mozc-ut # Moze with UT dictionary

      # Korean
      fcitx5-hangul
    ];
  };
}
