{
  makeDesktopItem,
  wechat-uos,
}:
makeDesktopItem {
  name = "wechat";
  desktopName = "WeChat";
  exec = "wechat-uos %U";
  terminal = false;
  # To find the icon name(nushell):
  #   let p = NIXPKGS_ALLOW_UNFREE=1 nix eval --impure nixpkgs#wechat-uos.outPath | str trim --char '"'
  #   tree $"($p)/share/icons"
  icon = "${wechat-uos}/share/icons/hicolor/256x256/apps/com.tencent.wechat.png";
  type = "Application";
  categories = ["Network"];
  comment = "Wechat boxed";
}
