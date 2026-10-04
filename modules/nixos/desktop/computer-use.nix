{
  config,
  lib,
  pkgs,
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
  imports = [ ./networking/mihomo ]; # also pulled in by the desktop scanPaths; explicit for clarity

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

    # Native mihomo runs the proxy as a system service (TUN), so the headless
    # session does not depend on a GUI starting the core. Its config lives at
    # ~/.config/mihomo/config.yaml (out of the Nix store).
    modules.networking.mihomo.enable = true;
  };
}
