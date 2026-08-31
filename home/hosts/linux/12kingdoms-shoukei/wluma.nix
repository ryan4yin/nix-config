{ ... }:
# Automatic brightness for shoukei (the only host with an ambient light
# sensor: aop-sensors-als, exposed through iio-sensor-proxy).
#
# wluma learns brightness preferences from manual adjustments (the QuickShell
# slider counts as training data), then adjusts the backlight automatically
# based on ambient light + screen contents.
#
# gamma = false keeps color temperature handled by noctalia's NightLight
# (zwlr-gamma-control is an exclusive protocol, wluma and noctalia cannot
# both own it). Other hosts keep the existing time-based NightLight setup.
#
# No extra udev rules or ACLs are needed: the sysfs brightness node is
# root-owned, so wluma falls back to the systemd-logind D-Bus API
# (org.freedesktop.login1.Session.SetBrightness), which authorizes active
# sessions. Verified working inside Home Manager's default PrivateUsers
# sandbox; do not "fix" it by disabling the sandbox.
{
  services.wluma = {
    enable = true;
    # Exactly one top-level ALS section is mandatory in wluma's config.
    # The als.iio path scans /sys/bus/iio/devices and picks up the AOP
    # ambient light sensor (aop-sensors-als) exported via iio-sensor-proxy.
    settings.als.iio = {
      path = "/sys/bus/iio/devices";
      thresholds = {
        "0" = "night";
        "20" = "dark";
        "80" = "dim";
        "250" = "normal";
        "500" = "bright";
        "800" = "outdoors";
      };
    };
    settings.output.backlight = [
      {
        name = "eDP-1";
        path = "/sys/class/backlight/apple-panel-bl";
        gamma = false;
      }
    ];
  };
}
