{
  lib,
  mylib,
  myvars,
  pkgs,
  ...
}:
{
  home.homeDirectory = "/Users/${myvars.username}";

  # home-manager's darwin module only forwards the system-level nix.package
  # when `nix.enable` is on, so provide a low-priority fallback here.
  nix.package = lib.mkDefault pkgs.nix;
  imports = (mylib.scanPaths ./.) ++ [
    ../base/core
    ../base/tui
    ../base/gui
    ../base/home.nix
  ];

  # enable management of XDG base directories on macOS.
  xdg.enable = true;
}
