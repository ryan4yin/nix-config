# XDG stands for "Cross-Desktop Group", with X used to mean "cross".
# It's a bunch of specifications from freedesktop.org intended to standardize desktops and
# other GUI applications on various systems (primarily Unix-like) to be interoperable:
#   https://www.freedesktop.org/wiki/Specifications/
{
  mylib,
  config,
  pkgs,
  ...
}:
{
  imports = mylib.scanPaths ./.;

  home.packages = with pkgs; [
    xdg-utils # provides cli tools such as `xdg-mime` `xdg-open`
    xdg-user-dirs
  ];

  xdg.userDirs = {
    enable = true;
    setSessionVariables = true;
    createDirectories = true;
    extraConfig = {
      SCREENSHOTS = "${config.xdg.userDirs.pictures}/Screenshots";
    };
  };
}
