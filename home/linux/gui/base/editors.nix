{ lib, pkgs-master, ... }:

let
  vscodeCliArgs = [
    # https://code.visualstudio.com/docs/configure/settings-sync#_recommended-configure-the-keyring-to-use-with-vs-code
    # For use with any package that implements the Secret Service API
    # (for example gnome-keyring, kwallet5, KeepassXC)
    "--password-store=gnome-libsecret"
  ];

  code-cursor =
    (pkgs-master.code-cursor.override {
      commandLineArgs = lib.concatStringsSep " " vscodeCliArgs;
    }).overrideAttrs
      (oldAttrs: rec {
        pname = "cursor";
        version = "2.0.77";
        src =
          with pkgs-master;
          appimageTools.extract {
            inherit pname version;
            src =
              let
                sources = {
                  x86_64-linux = fetchurl {
                    # curl -s https://api2.cursor.sh/updates/api/download/stable/linux-x64/cursor | jq
                    url = "https://downloads.cursor.com/production/ba90f2f88e4911312761abab9492c42442117cfe/linux/x64/Cursor-2.0.77-x86_64.AppImage";
                    hash = "sha256-/r7cmjgFhec7fEKUfFKw3vUoB9LJB2P/646cMeRKp/0=";
                  };
                  aarch64-linux = fetchurl {
                    # curl -s https://api2.cursor.sh/updates/api/download/stable/linux-arm64/cursor | jq
                    url = "https://downloads.cursor.com/production/ba90f2f88e4911312761abab9492c42442117cfe/linux/arm64/Cursor-2.0.77-aarch64.AppImage";
                    hash = "sha256-VKN9FAHjFTcdkUeBO2cLs92w6qzAbPl2kypTluRxbBA=";
                  };
                };
              in
              sources.${stdenv.hostPlatform.system};
          };
        sourceRoot = "${pname}-${version}-extracted/usr/share/cursor";
      });
in
{
  home.packages = with pkgs-master; [
    zed-editor
    code-cursor
  ];

  programs.vscode = {
    enable = true;
    package = pkgs-master.vscode.override {
      commandLineArgs = vscodeCliArgs;
    };
  };
}
