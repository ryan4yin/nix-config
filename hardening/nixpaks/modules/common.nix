# https://github.com/mnixry/nixos-config/blob/74913c2b90d06e31170bbbaa0074f915721da224/desktop/packages/nixpaks-common.nix
# https://github.com/Kraftland/portable/blob/09c4a4227538a3f42de208a6ecbdc938ac9c00dd/portable.sh
# https://flatpak.github.io/xdg-desktop-portal/docs/api-reference.html
{
  lib,
  sloth,
  config,
  ...
}:
let
  inherit (config.flatpak) appId;
in
{
  config = {
    # list all dbus services:
    #   ls -al /run/current-system/sw/share/dbus-1/services/
    #   ls -al /etc/profiles/per-user/ryan/share/dbus-1/services/
    dbus = {
      # `--see`: The bus name can be enumerated by the application.
      # `--talk`: The application can send messages to, and receive replies and signals from, the bus name.
      # `--own`: The application can own the bus name
      policies = {
        "${appId}" = "own";
        "${appId}.*" = "own";
        "org.freedesktop.DBus" = "talk";
        "ca.desrt.dconf" = "talk";
        "org.freedesktop.appearance" = "talk";
        "org.freedesktop.appearance.*" = "talk";
      }
      // (builtins.listToAttrs (
        map (id: lib.nameValuePair "org.kde.StatusNotifierItem-${toString id}-1" "own") (
          lib.lists.range 2 29
        )
      ))
      // {
        # --- MPRIS Media Control ---
        # Allows the app to register as a media player. These are derived from the appID.
        "org.mpris.MediaPlayer2.${appId}" = "own";
        "org.mpris.MediaPlayer2.${appId}.*" = "own";
        "org.mpris.MediaPlayer2.${lib.lists.last (lib.strings.splitString "." appId)}" = "own";
        "org.mpris.MediaPlayer2.${lib.lists.last (lib.strings.splitString "." appId)}.*" = "own";

        # --- General Desktop Integration ---
        "com.canonical.AppMenu.Registrar" = "talk"; # For Ubuntu AppMenu
        "org.freedesktop.FileManager1" = "talk";
        "org.freedesktop.Notifications" = "talk";
        "org.kde.StatusNotifierWatcher" = "talk";
        "org.gnome.Shell.Screencast" = "talk";

        # --- Accessibility (a11y) 无障碍服务 ---
        "org.a11y.Bus" = "see";

        # --- Portal Access ---
        # "org.freedesktop.portal.*" = "talk";
        "org.freedesktop.portal.Documents" = "talk";
        "org.freedesktop.portal.FileTransfer" = "talk";
        "org.freedesktop.portal.FileTransfer.*" = "talk";
        "org.freedesktop.portal.Notification" = "talk";
        "org.freedesktop.portal.OpenURI" = "talk";
        "org.freedesktop.portal.OpenURI.OpenFile" = "talk";
        "org.freedesktop.portal.OpenURI.OpenURI" = "talk";
        "org.freedesktop.portal.Print" = "talk";
        "org.freedesktop.portal.Request" = "see";

        # --- Input Method Portals ---
        "org.freedesktop.portal.Fcitx" = "talk";
        "org.freedesktop.portal.Fcitx.*" = "talk";
        "org.freedesktop.portal.IBus" = "talk";
        "org.freedesktop.portal.IBus.*" = "talk";
      };
      # '--call' rules permit specific method calls on D-Bus interfaces.
      rules.call = {
        # --- Accessibility (a11y) 无障碍服务 ---
        "org.a11y.Bus" = [
          "org.a11y.Bus.GetAddress@/org/a11y/bus"
          "org.freedesktop.DBus.Properties.Get@/org/a11y/bus"
        ];

        # --- General Portal Rules ---
        "org.freedesktop.FileManager1" = [ "*" ];
        "org.freedesktop.Notifications.*" = [ "*" ];
        "org.freedesktop.portal.Documents" = [ "*" ];
        "org.freedesktop.portal.FileTransfer" = [ "*" ];
        "org.freedesktop.portal.FileTransfer.*" = [ "*" ];
        "org.freedesktop.portal.Fcitx" = [ "*" ];
        "org.freedesktop.portal.Fcitx.*" = [ "*" ];
        "org.freedesktop.portal.IBus" = [ "*" ];
        "org.freedesktop.portal.IBus.*" = [ "*" ];
        "org.freedesktop.portal.Notification" = [ "*" ];
        "org.freedesktop.portal.OpenURI" = [ "*" ];
        "org.freedesktop.portal.OpenURI.OpenFile" = [ "*" ];
        "org.freedesktop.portal.OpenURI.OpenURI" = [ "*" ];
        "org.freedesktop.portal.Print" = [ "*" ];
        "org.freedesktop.portal.Request" = [ "*" ];

        # --- Main Desktop Portal Interface ---
        # A comprehensive list of permissions for interacting with the desktop environment.
        "org.freedesktop.portal.Desktop" = [
          # Properties & Settings
          "org.freedesktop.DBus.Properties.GetAll"
          "org.freedesktop.DBus.Properties.Get@/org/freedesktop/portal/desktop"
          "org.freedesktop.portal.Session.Close"
          "org.freedesktop.portal.Settings.ReadAll"
          "org.freedesktop.portal.Settings.Read"
          "org.freedesktop.portal.Account.GetUserInformation"

          # Network & Proxy
          "org.freedesktop.portal.NetworkMonitor"
          "org.freedesktop.portal.NetworkMonitor.*"
          "org.freedesktop.portal.ProxyResolver.Lookup"
          "org.freedesktop.portal.ProxyResolver.Lookup.*"

          # Screenshot / Screen Capture & Sharing
          "org.freedesktop.portal.ScreenCast"
          "org.freedesktop.portal.ScreenCast.*"
          "org.freedesktop.portal.Screenshot"
          "org.freedesktop.portal.Screenshot.Screenshot"

          # Device Access(Camera / USB)
          "org.freedesktop.portal.Camera"
          "org.freedesktop.portal.Camera.*"
          "org.freedesktop.portal.Usb"
          "org.freedesktop.portal.Usb.*"

          # Remote Desktop
          "org.freedesktop.portal.RemoteDesktop"
          "org.freedesktop.portal.RemoteDesktop.*"

          # File Operations
          "org.freedesktop.portal.Documents"
          "org.freedesktop.portal.Documents.*"
          "org.freedesktop.portal.FileChooser"
          "org.freedesktop.portal.FileChooser.*"
          "org.freedesktop.portal.FileTransfer"
          "org.freedesktop.portal.FileTransfer.*"

          # Notifications & Printing
          "org.freedesktop.portal.Notification"
          "org.freedesktop.portal.Notification.*"
          "org.freedesktop.portal.Print"
          "org.freedesktop.portal.Print.*"

          # Open/Launch Handlers
          "org.freedesktop.portal.OpenURI"
          "org.freedesktop.portal.OpenURI.*"
          "org.freedesktop.portal.Email.ComposeEmail"

          # Input Methods
          "org.freedesktop.portal.Fcitx"
          "org.freedesktop.portal.Fcitx.*"
          "org.freedesktop.portal.IBus"
          "org.freedesktop.portal.IBus.*"

          # Secrets (Keyring)
          "org.freedesktop.portal.Secret"
          "org.freedesktop.portal.Secret.RetrieveSecret"

          # Get/Update GlobalShortcuts
          # "org.freedesktop.portal.GlobalShortcuts"
          # "org.freedesktop.portal.GlobalShortcuts.*"

          # -- get the user's location
          # "org.freedesktop.portal.Location"
          # "org.freedesktop.portal.Location.*"

          # -- inhibit the user session from ending, suspending, idling or getting switched away.
          "org.freedesktop.portal.Inhibit"
          "org.freedesktop.portal.Inhibit.*"

          # Generic Request Fallback
          "org.freedesktop.portal.Request"
        ];
      };

      # 'broadcast' rules permit receiving signals from D-Bus names.
      rules.broadcast = {
        "org.freedesktop.portal.*" = [ "@/org/freedesktop/portal/*" ];
      };
      args = [
        "--filter"
        "--sloppy-names"
        "--log"
      ];
    };

    etc.sslCertificates.enable = true;
    bubblewrap = {
      network = lib.mkDefault true;
      sockets = {
        wayland = true;
        pulse = true;
      };

      bind.rw = with sloth; [
        [
          (mkdir appDataDir)
          xdgDataHome
        ]
        [
          (mkdir appConfigDir)
          xdgConfigHome
        ]
        [
          (mkdir appCacheDir)
          xdgCacheHome
        ]

        (sloth.concat [
          sloth.runtimeDir
          "/"
          (sloth.envOr "WAYLAND_DISPLAY" "no")
        ])
        (sloth.concat' sloth.runtimeDir "/at-spi/bus")
        (sloth.concat' sloth.runtimeDir "/gvfsd")
        (sloth.concat' sloth.runtimeDir "/dconf")

        (sloth.concat' sloth.xdgCacheHome "/fontconfig")
        (sloth.concat' sloth.xdgCacheHome "/mesa_shader_cache")
        (sloth.concat' sloth.xdgCacheHome "/mesa_shader_cache_db")
        (sloth.concat' sloth.xdgCacheHome "/radv_builtin_shaders")
      ];
      bind.ro = [
        (sloth.concat' sloth.runtimeDir "/doc")
        (sloth.concat' sloth.xdgConfigHome "/kdeglobals")
        (sloth.concat' sloth.xdgConfigHome "/gtk-2.0")
        (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
        (sloth.concat' sloth.xdgConfigHome "/gtk-4.0")
        (sloth.concat' sloth.xdgConfigHome "/fontconfig")
        (sloth.concat' sloth.xdgConfigHome "/dconf")
      ];
      bind.dev = [ "/dev/shm" ] ++ (map (id: "/dev/video${toString id}") (lib.lists.range 0 9));
    };
  };
}
