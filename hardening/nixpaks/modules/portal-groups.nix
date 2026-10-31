# xdg-dbus-proxy rules target interfaces on the Desktop bus name, not fictitious
# per-interface bus names. Each capability is opt-in.
{ config, lib, ... }:
let
  groups = {
    fileChooser = [
      "FileChooser.OpenFile"
      "FileChooser.SaveFile"
      "FileChooser.SaveFiles"
    ];
    openUri = [
      "OpenURI.OpenURI"
      "OpenURI.OpenFile"
      "OpenURI.OpenDirectory"
    ];
    notifications = [
      "Notification.AddNotification"
      "Notification.RemoveNotification"
    ];
    screenCast = [
      "ScreenCast.CreateSession"
      "ScreenCast.SelectSources"
      "ScreenCast.Start"
      "ScreenCast.OpenPipeWireRemote"
    ];
    camera = [
      "Camera.AccessCamera"
      "Camera.OpenPipeWireRemote"
    ];
    print = [
      "Print.PreparePrint"
      "Print.Print"
    ];
    secret = [ "Secret.RetrieveSecret" ];
    inhibit = [
      "Inhibit.Inhibit"
      "Inhibit.CreateMonitor"
      "Inhibit.QueryEndResponse"
    ];
  };
in
{
  options.portalGroups =
    lib.mapAttrs (name: _: lib.mkEnableOption "the ${name} desktop portal methods") groups
    // {
      inputMethod = lib.mkEnableOption "Fcitx and IBus input method portals";
    };
  config = {
    dbus.rules.call."org.freedesktop.portal.Desktop" = lib.concatLists (
      lib.mapAttrsToList (
        name: methods:
        lib.optionals config.portalGroups.${name} (
          map (method: "org.freedesktop.portal.${method}@/org/freedesktop/portal/desktop") methods
        )
      ) groups
    );
    dbus.policies = lib.mkIf config.portalGroups.inputMethod {
      "org.freedesktop.portal.Fcitx" = "talk";
      "org.freedesktop.portal.IBus" = "talk";
    };
  };
}
