{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    # GUI apps
    # e-book viewer(.epub/.mobi/...)
    # do not support .pdf
    foliate

    # remote desktop(rdp connect)
    remmina
    freerdp # required by remmina

    # my custom hardened packages
    nixpaks.qq
    nixpaks.telegram-desktop
    bwraps.wechat
    # discord # update too frequently, use the web version instead
  ];

  # Fonts install at system level, not user level, so fontconfig does not
  # scan home.packages for them.
  fonts.fontconfig.enable = false;

}
