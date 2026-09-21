{
  config,
  lib,
  pkgs,
  pkgs-master,
  myvars,
  ...
}:
let
  cfg = config.modules.desktop.computerUse;
  username = myvars.username;

  # Keep the guest timezone consistent with the proxy's exit region. A
  # China-based timezone with a US/JP exit IP is a strong automation signal.
  timeZone = if cfg.proxyRegion == "jp" then "Asia/Tokyo" else "America/Los_Angeles";
in
{
  options.modules.desktop.computerUse = {
    enable = lib.mkEnableOption "headless computer-use environment (X11 + desktop automation)";
    proxyRegion = lib.mkOption {
      type = lib.types.enum [
        "us"
        "jp"
      ];
      default = "us";
      description = "Proxy exit region; keeps the timezone consistent with the egress IP.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users."${username}".linger = true;

    # computer-use-linux / cua-driver read the AT-SPI accessibility tree.
    services.gnome.at-spi2-core.enable = true;

    # A sparse font set is itself a browser fingerprinting signal, so ship the
    # same rich font set the desktops use.
    modules.desktop.fonts.enable = true;

    # Mesa userspace (software GL for X11).
    hardware.graphics.enable = true;

    # Match the proxy's exit region.
    time.timeZone = lib.mkForce timeZone;

    # Browsers keep their profile/preferences in dconf.
    programs.dconf.enable = true;

    # Clash Verge provides the proxy. Its core is started by the GUI, which is
    # launched inside the session; service mode + TUN mode come from the module.
    programs.clash-verge = {
      enable = true;
      package = pkgs-master.clash-verge-rev;
      serviceMode = true;
      tunMode = true;
    };
  };
}
