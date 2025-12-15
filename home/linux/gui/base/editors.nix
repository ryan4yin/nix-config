{
  lib,
  pkgs,
  pkgs-master,
  ...
}:

let
  vscodeCliArgs = [
    # https://code.visualstudio.com/docs/configure/settings-sync#_recommended-configure-the-keyring-to-use-with-vs-code
    # For use with any package that implements the Secret Service API
    # (for example gnome-keyring, kwallet5, KeepassXC)
    "--password-store=gnome-libsecret"
  ];

  code-cursor = pkgs-master.code-cursor;
  # (pkgs-master.code-cursor.override {
  #   commandLineArgs = lib.concatStringsSep " " vscodeCliArgs;
  # }).overrideAttrs
  #   (oldAttrs: rec {
  #     pname = "cursor";
  #     version = "2.1.36";
  #     src =
  #       with pkgs-master;
  #       appimageTools.extract {
  #         inherit pname version;
  #         src =
  #           let
  #             sources = {
  #               x86_64-linux = fetchurl {
  #                 # curl -s https://api2.cursor.sh/updates/api/download/stable/linux-x64/cursor | jq
  #                 url = "https://downloads.cursor.com/production/9cd7c8b6cebcbccc1242df211dee45a4b6fe15e4/linux/x64/Cursor-2.1.36-x86_64.AppImage";
  #                 hash = "sha256-aaprRB2BAaUCHj7m5aGacCBHisjN2pVZ+Ca3u1ifxBA=";
  #               };
  #               aarch64-linux = fetchurl {
  #                 # curl -s https://api2.cursor.sh/updates/api/download/stable/linux-arm64/cursor | jq
  #                 url = "https://downloads.cursor.com/production/9cd7c8b6cebcbccc1242df211dee45a4b6fe15e4/linux/arm64/Cursor-2.1.36-aarch64.AppImage";
  #                 hash = "sha256-S2vFYBI6m0zjBJEDbk7gc6/zFiKWyhM73OUm1xsNx6Q=";
  #               };
  #             };
  #           in
  #           sources.${stdenv.hostPlatform.system};
  #       };
  #     sourceRoot = "${pname}-${version}-extracted/usr/share/cursor";
  #   });
in
{
  home.packages = [
    pkgs.zed-editor
    code-cursor
  ];

  programs.vscode = {
    enable = true;
    package = pkgs-master.vscode.override {
      commandLineArgs = vscodeCliArgs;
    };
  };
}
