{
  lib,
  pkgs-master,
  ...
}:

{
  programs.vscode = {
    # Extensions and settings are managed by VS Code's built-in Settings Sync,
    # not declaratively here (persisted via `.config/Code`, see preservation).
    enable = true;
    package = pkgs-master.vscode.override {
      commandLineArgs = [
        # https://code.visualstudio.com/docs/configure/settings-sync#_recommended-configure-the-keyring-to-use-with-vs-code
        # For use with any package that implements the Secret Service API
        # (for example gnome-keyring, kwallet5, KeepassXC)
        "--password-store=gnome-libsecret"
      ];
    };
  };
}
