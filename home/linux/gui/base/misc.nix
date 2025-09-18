{
  pkgs,
  pkgs-unstable,
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
    pkgs.nixpaks.qq
    pkgs.nixpaks.telegram-desktop
    # qqmusic
    pkgs.bwraps.wechat
    # discord # update too frequently, use the web version instead
  ];

  # allow fontconfig to discover fonts and configurations installed through home.packages
  # Install fonts at system-level, not user-level
  fonts.fontconfig.enable = false;
}
