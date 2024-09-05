{
  makeDesktopItem,
  qq,
}:
makeDesktopItem {
  name = "qq";
  desktopName = "QQ";
  exec = "qq %U";
  terminal = false;
  # icon = "qq";
  icon = "${qq}/share/icons/hicolor/512x512/apps/qq.png";
  type = "Application";
  categories = ["Network"];
  comment = "QQ boxed";
}
