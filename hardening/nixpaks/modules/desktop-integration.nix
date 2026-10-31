# Non-portal desktop services are separate opt-ins from portal capabilities.
{
  config,
  lib,
  sloth,
  ...
}:
let
  cfg = config.desktopIntegration;
  appId = config.flatpak.appId;
  shortName = lib.last (lib.splitString "." appId);
in
{
  options.desktopIntegration = {
    notifications = lib.mkEnableOption "native desktop notifications";
    tray = lib.mkEnableOption "StatusNotifier tray integration";
    mpris = lib.mkEnableOption "MPRIS media controls for this application";
    accessibility = lib.mkEnableOption "the accessibility bus and AT-SPI socket";
  };
  config = lib.mkMerge [
    (lib.mkIf cfg.notifications {
      dbus.policies."org.freedesktop.Notifications" = "talk";
    })
    (lib.mkIf cfg.tray {
      dbus.policies = {
        # Qt probes NameHasOwner/GetNameOwner before registering its SNI.
        "org.freedesktop.DBus" = "talk";
        "org.kde.StatusNotifierWatcher" = "talk";
      }
      # SNI name is <pid>-<Qt tray instance ID>; WeChat 4.1.13 uses <pid>-2.
      // builtins.listToAttrs (
        lib.concatMap (
          id:
          map (
            instance: lib.nameValuePair "org.kde.StatusNotifierItem-${toString id}-${toString instance}" "own"
          ) (lib.range 1 5)
        ) (lib.range 2 5)
      );
    })
    (lib.mkIf cfg.mpris {
      # Chromium's MPRIS name is lowercase even though its app ID ends in
      # Chromium; retain the full ID and toolkit spelling as well.
      dbus.policies = builtins.listToAttrs (
        lib.concatMap
          (name: [
            (lib.nameValuePair "org.mpris.MediaPlayer2.${name}" "own")
            (lib.nameValuePair "org.mpris.MediaPlayer2.${name}.*" "own")
          ])
          (
            lib.unique [
              appId
              shortName
              (lib.toLower shortName)
            ]
          )
      );
    })
    (lib.mkIf cfg.accessibility {
      dbus.policies."org.a11y.Bus" = "see";
      dbus.rules.call."org.a11y.Bus" = [
        "org.a11y.Bus.GetAddress@/org/a11y/bus"
        "org.freedesktop.DBus.Properties.Get@/org/a11y/bus"
      ];
      bubblewrap.bind.ro = [ (sloth.concat' sloth.runtimeDir "/at-spi/bus") ];
    })
  ];
}
