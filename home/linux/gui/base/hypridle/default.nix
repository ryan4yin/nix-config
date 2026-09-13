{
  config,
  lib,
  ...
}:
let
  cfg = config.modules.desktop.hypridle;
in
{
  options.modules.desktop.hypridle = {
    keyboardBacklightTimeout = lib.mkOption {
      type = lib.types.int;
      description = "Seconds of idle before turning off the keyboard backlight.";
    };
    screenOffTimeout = lib.mkOption {
      type = lib.types.int;
      description = "Seconds of idle before turning off the monitors (DPMS).";
    };
    lockTimeout = lib.mkOption {
      type = lib.types.int;
      description = "Seconds of idle before locking the screen.";
    };
  };

  config = {
    # Hyprland/niri idle daemon. Declared in Nix (instead of a raw
    # hypridle.conf) so each host can tune the timeouts below.
    services.hypridle = {
      enable = true;

      settings = {
        general = {
          lock_cmd = "noctalia-shell ipc call lockScreen lock";
          before_sleep_cmd = "noctalia-shell ipc call lockScreen lock";
          ignore_dbus_inhibit = false;
        };

        listener = [
          {
            timeout = cfg.keyboardBacklightTimeout;
            # brightnessctl --list / -d kbd_backlight
            on-timeout = "brightnessctl --save --device=kbd_backlight set 0";
            on-resume = "brightnessctl --restore --device=kbd_backlight";
          }
          {
            timeout = cfg.screenOffTimeout;
            ignore_inhibit = true;
            # Some apps keep idle-inhibit active even when they are only sitting
            # on a page, which can prevent screen-off forever. Ignore those
            # inhibitors for screen-off, but skip while an MPRIS player reports
            # active playback.
            condition_cmd = "! playerctl -a status 2>/dev/null | grep -q '^Playing$'";
            condition_retry = 30;
            on-timeout = "niri msg action power-off-monitors";
            on-resume = "niri msg action power-on-monitors";
          }
          {
            timeout = cfg.lockTimeout;
            ignore_inhibit = true;
            on-timeout = "noctalia-shell ipc call lockScreen lock";
          }
        ];
      };
    };
  };
}
