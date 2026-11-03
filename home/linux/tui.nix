# Home role of the `agent` profile (hosts/README.md#host-profiles): the full
# TUI stack for a headless host.
{
  imports = [
    ../base/core
    ../base/tui
    ../base/home.nix

    ./base
    # off by default; a host turns it on with modules.desktop.computerUse.enable
    ./gui/i3
  ];

  # ~/.secrets is synced to the desktops only.
  modules.shell.secrets.enable = false;
}
