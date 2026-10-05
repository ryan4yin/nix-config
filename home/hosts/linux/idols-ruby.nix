{
  imports = [
    ../../linux/core.nix
    ../../linux/gui/i3
    # Ruby installs the dsh CLI system-wide from `hosts/idols-ruby/packages.nix`
    # while running the core home stack, so it misses the agents module that the
    # GUI hosts pull in through `home/linux/gui.nix`. Import just the dsh
    # profile, which keeps its Settings-owned configuration in this repository.
    ../../base/tui/agents/dsh
  ];

  # Headless X11/i3 session for computer use.
  modules.desktop.computerUse.enable = true;
  # localhost-only VNC server for manual access (use an SSH tunnel).
  modules.desktop.computerUse.vnc = true;
  # trycua/cua driver, grey-tested on ruby only.
  modules.desktop.computerUse.cuaDriver = true;
}
