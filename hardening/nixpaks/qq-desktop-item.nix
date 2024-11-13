{
  makeDesktopItem,
  qq,
}:
makeDesktopItem {
  name = "qq";
  desktopName = "QQ";
  exec = "qq %U";
  terminal = false;
  # To find the icon name(nushell):
  #   let p = NIXPKGS_ALLOW_UNFREE=1 nix eval --impure nixpkgs#qq.outPath | str trim --char '"'
  #   tree $"($p)/share/icons"
  icon = "${qq}/share/icons/hicolor/512x512/apps/qq.png";
  type = "Application";
  categories = ["Network"];
  comment = "QQ boxed";
}
