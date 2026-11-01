{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    # GUI apps
    # e-book viewer(.epub/.mobi/...)
    # do not support .pdf
    nixpaks.foliate

    # remote desktop (RDP/VNC/SPICE)
    nixpaks.remmina
    freerdp # CLI fallback and Remmina runtime dependency

    # my custom hardened packages
    nixpaks.qq
    nixpaks.telegram-desktop
    nixpaks.wechat
    # discord # update too frequently, use the web version instead
  ];

  # Fonts install at system level, not user level, so fontconfig does not
  # scan home.packages for them.
  fonts.fontconfig.enable = false;

}
