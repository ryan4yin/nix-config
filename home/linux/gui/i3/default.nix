{
  pkgs,
  pkgs-x64,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.desktop.computerUse;

  display = ":0";
  screen = "1920x1080x24";

  # Keep this list minimal: the goal is to look like a real user device, not to
  # harden the browser. The browser goes out through Clash Verge's proxy, so
  # non-proxied WebRTC UDP must stay disabled (a real IP leak would contradict
  # the exit region); everything else is a stock-looking setting.
  browserFlags = [
    "--force-webrtc-ip-handling-policy=disable_non_proxied_udp"
    "--disable-blink-features=AutomationControlled"
    "--force-renderer-accessibility"
    "--lang=en-US"
    "--window-size=1920,1080"
    "--window-position=0,0"
    "--no-first-run"
    "--no-default-browser-check"
  ];

  # Exec'd by i3 once the X session is up.
  initScript = pkgs.writeShellScript "computer-use-init" ''
    set -eu

    # Make the X session visible to the systemd/dbus user manager, so MCP
    # servers and other user services started later inherit DISPLAY.
    export DISPLAY=${display}
    ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd \
      DISPLAY XDG_SESSION_TYPE XDG_CURRENT_DESKTOP || true

    # This is an X11 session: drop any stale Wayland variables (left over from
    # a previous session), otherwise tools such as x11vnc refuse to start.
    ${pkgs.systemd}/bin/systemctl --user unset-environment WAYLAND_DISPLAY || true

    # Enable the AT-SPI bridge so computer-use agents can read accessibility
    # trees. at-spi-bus-launcher derives org.a11y.Status.IsEnabled from this key.
    GSETTINGS_BACKEND=dconf \
      DBUS_SESSION_BUS_ADDRESS="unix:path=''${XDG_RUNTIME_DIR}/bus" \
      ${pkgs.glib.bin}/bin/gsettings set org.gnome.desktop.interface toolkit-accessibility true \
      >/dev/null 2>&1 || true

    ${lib.optionalString cfg.cuaDriver ''
      # cua-driver sends content-free telemetry by default; turn it off.
      ${pkgs-x64.cua-driver}/bin/cua-driver telemetry disable >/dev/null 2>&1 || true
    ''}
  '';
in
{
  options.modules.desktop.computerUse = {
    enable = lib.mkEnableOption "headless X11/i3 session for computer use";
    vnc = lib.mkEnableOption "a localhost-only x11vnc server for manual access";
    cuaDriver = lib.mkEnableOption "the trycua/cua driver (cua-driver)";
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        glib # gsettings, to enable the AT-SPI bridge
        gsettings-desktop-schemas # the toolkit-accessibility schema
        i3
        kitty # terminal (supports X11 and Wayland)
        xdotool # XTEST input (fallback / manual use)
        xclip # clipboard
        xvfb # headless X server
      ]
      ++ [
        # MCP server / CLI that drives the desktop (see overlays/computer-use-linux.nix).
        pkgs-x64.computer-use-linux
      ]
      ++ lib.optional cfg.vnc pkgs.x11vnc
      ++ lib.optional cfg.cuaDriver pkgs-x64.cua-driver;

    # Headless X server.
    systemd.user.services.xvfb = {
      Unit = {
        Description = "Xvfb headless X server";
      };
      Install.WantedBy = [ "default.target" ];
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.xvfb}/bin/Xvfb ${display} -screen 0 ${screen} -nolisten tcp";
        Restart = "always";
        RestartSec = 2;
      };
    };

    # Window manager.
    systemd.user.services.i3 = {
      Unit = {
        Description = "i3 window manager (headless X)";
        After = [ "xvfb.service" ];
        Requires = [ "xvfb.service" ];
      };
      Install.WantedBy = [ "default.target" ];
      Service = {
        Type = "simple";
        Environment = [
          "DISPLAY=${display}"
          "XDG_SESSION_TYPE=x11"
          "XDG_CURRENT_DESKTOP=i3"
        ];
        ExecStart = "${pkgs.i3}/bin/i3";
        Restart = "always";
        RestartSec = 2;
      };
    };

    # Optional VNC server for manual access; localhost only, use an SSH tunnel.
    systemd.user.services.x11vnc = lib.mkIf cfg.vnc {
      Unit = {
        Description = "x11vnc (localhost) for manual access";
        After = [ "xvfb.service" ];
        Wants = [ "xvfb.service" ];
      };
      Install.WantedBy = [ "default.target" ];
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.x11vnc}/bin/x11vnc -display ${display} -localhost -nopw -forever -shared -rfbport 5900";
        Restart = "always";
        RestartSec = 2;
      };
    };

    # cua-driver daemon, so `cua-driver mcp` / `call` can reach it.
    systemd.user.services.cua-driver = lib.mkIf cfg.cuaDriver {
      Unit = {
        Description = "cua-driver daemon";
        After = [
          "xvfb.service"
          "i3.service"
        ];
        Wants = [ "xvfb.service" ];
      };
      Install.WantedBy = [ "default.target" ];
      Service = {
        Type = "simple";
        Environment = [
          "DISPLAY=${display}"
          "XDG_SESSION_TYPE=x11"
        ];
        ExecStart = "${pkgs-x64.cua-driver}/bin/cua-driver serve";
        Restart = "always";
        RestartSec = 2;
      };
    };

    xdg.configFile."i3/config".text = ''
      # i3 configuration for the headless computer-use session.
      # Keep it minimal; see README.md in this directory for the rationale.

      font pango:monospace 10
      default_border normal

      exec --no-startup-id ${initScript}
    '';

    programs.brave-origin = {
      enable = true;
      commandLineArgs = browserFlags;
    };
    programs.chromium = {
      enable = true;
      commandLineArgs = browserFlags;
    };
  };
}
