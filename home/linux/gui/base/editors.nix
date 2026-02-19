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
in
{
  home.packages = [
    pkgs-master.code-cursor
    # pkgs-master.zed-editor
    # pkgs-master.antigravity-fhs
  ];

  programs.vscode = {
    enable = true;
    package = pkgs-master.vscode.override {
      commandLineArgs = vscodeCliArgs;
    };
  };
}
