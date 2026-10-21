{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.desktop.hypridle;
  python = pkgs.python3.withPackages (ps: [
    ps.evdev
    ps.pulsectl
    ps.pyudev
  ]);
  activityMonitor = pkgs.writeShellApplication {
    name = "hypridle-activity";
    runtimeInputs = [ pkgs.playerctl ];
    text = ''
      exec ${python}/bin/python3 ${./activity_monitor.py} "$@"
    '';
  };
  activityCheck = timeout: "${lib.getExe activityMonitor} check --timeout ${toString timeout}";
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
    home.packages = [ activityMonitor ];
    systemd.user.services.hypridle-activity = {
      Unit = {
        Description = "Gamepad and media activity monitor for hypridle";
        After = [
          config.services.hypridle.systemdTarget
          "pipewire-pulse.service"
        ];
        PartOf = [ config.services.hypridle.systemdTarget ];
      };
      Service = {
        ExecStart = "${lib.getExe activityMonitor} daemon";
        Restart = "on-failure";
        RestartSec = 3;
        RuntimeDirectory = "hypridle-activity";
        RuntimeDirectoryMode = "0700";
        UMask = "0077";
      };
      Install.WantedBy = [ config.services.hypridle.systemdTarget ];
    };

    # Hyprland/niri idle daemon. Declared in Nix (instead of a raw
    # hypridle.conf) so each host can tune the timeouts below.
    services.hypridle = {
      enable = true;

      settings = {
        general = {
          lock_cmd = "noctalia msg session lock";
          before_sleep_cmd = "noctalia msg session lock";
          # niri already owns org.freedesktop.ScreenSaver and feeds its
          # inhibitors into the compositor idle notifier, so hypridle must not
          # try to claim the interface (it would log "already providing...").
          ignore_dbus_inhibit = true;
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
            # App inhibitors can outlive playback; use observed activity instead.
            condition_cmd = activityCheck cfg.screenOffTimeout;
            condition_retry = 30;
            on-timeout = "niri msg action power-off-monitors";
            on-resume = "niri msg action power-on-monitors";
          }
          {
            timeout = cfg.lockTimeout;
            ignore_inhibit = true;
            condition_cmd = activityCheck cfg.lockTimeout;
            condition_retry = 30;
            on-timeout = "noctalia msg session lock";
          }
        ];
      };
    };
  };
}
