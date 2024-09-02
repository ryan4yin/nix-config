{
  makeDesktopItem,
  firefox,
}:
makeDesktopItem {
  name = "firefox";
  desktopName = "firefox";
  exec = "firefox %U";
  terminal = false;
  # icon = "firefox";
  icon = "${firefox}/share/icons/hicolor/512x512/apps/firefox.png";
  type = "Application";
  categories = ["Network"];
  comment = "firefox boxed";
}
