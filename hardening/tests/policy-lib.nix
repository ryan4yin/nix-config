{ pkgs, mkNixPak }:
let
  inherit (pkgs) lib;

  load = name: (pkgs.callPackage (../nixpaks + "/${name}.nix") { inherit mkNixPak; }).config;

  # Wrapper files are the source of truth for the app inventory. The test
  # loader compares this with the per-app suites under ./policy.
  appNames = map (lib.removeSuffix ".nix") (
    builtins.attrNames (
      lib.filterAttrs (
        name: type: type == "regular" && name != "default.nix" && lib.hasSuffix ".nix" name
      ) (builtins.readDir ../nixpaks)
    )
  );
  apps = map load appNames;

  mountStrings =
    app: builtins.filter builtins.isString (lib.flatten (with app.bubblewrap.bind; rw ++ ro ++ dev));

  forbiddenDbus =
    argument:
    lib.any (name: lib.hasInfix name argument) [
      "org.freedesktop.portal.Usb"
      "org.freedesktop.portal.RemoteDesktop"
      "org.gnome.Shell.Screencast"
    ]
    || argument == "--talk=org.freedesktop.portal.Desktop";

  withoutSecretPortal =
    calls:
    calls
    // {
      "org.freedesktop.portal.Desktop" = lib.filter (
        arg: !lib.hasInfix "org.freedesktop.portal.Secret" arg
      ) calls."org.freedesktop.portal.Desktop";
    };

  forbiddenMount =
    path:
    path == "/dev"
    || lib.hasPrefix "/dev/video" path
    || lib.hasPrefix "/dev/bus/usb" path
    || path == "/run/dbus"
    || path == "/run/dbus/system_bus_socket";

  hasHostFontconfig = app: lib.elem [ "/etc/static/fonts" "/etc/fonts" ] app.bubblewrap.bind.ro;

  hasPrivateTmp =
    app:
    let
      tmpPath = lib.findFirst (
        entry: builtins.isList entry && builtins.length entry == 2 && builtins.elem "/tmp" entry
      ) null app.bubblewrap.bind.rw;
    in
    builtins.isList tmpPath && builtins.length tmpPath == 2;

  hasDbusFragment = app: fragment: lib.any (argument: lib.hasInfix fragment argument) app.dbus.args;

  networkCheck =
    app: mode:
    if mode == "host" then
      app.bubblewrap.network && !app.pasta.enable
    else if mode == "pasta" then
      app.bubblewrap.network
      && app.pasta.enable
      && app.pasta.mode == "isolate"
      && lib.elem "--no-map-gw" app.pasta.args
    else if mode == "none" then
      !app.bubblewrap.network && !app.pasta.enable
    else
      throw "unknown network mode for ${app.flatpak.appId}: ${mode}";

  mediaCheck =
    app: expected:
    if expected then
      app.portalGroups.camera && app.portalGroups.screenCast
    else
      !app.bubblewrap.sockets.pipewire
      && !app.portalGroups.camera
      && !app.portalGroups.screenCast
      && !(hasDbusFragment app "org.freedesktop.portal.Camera")
      && !(hasDbusFragment app "org.freedesktop.portal.ScreenCast");

  secretPortalCheck =
    app: expected:
    if expected then
      (app.browserPermissions.secretPortal or false)
      && lib.any (
        argument:
        argument
        == "--call=org.freedesktop.portal.Desktop=org.freedesktop.portal.Secret.RetrieveSecret@/org/freedesktop/portal/desktop"
      ) app.dbus.args
    else
      !(app.browserPermissions.secretPortal or false)
      && !(hasDbusFragment app "org.freedesktop.portal.Secret");

  trayCheck =
    app: expected:
    if expected then
      app.desktopIntegration.tray
      && (app.dbus.policies."org.freedesktop.DBus" or null) == "talk"
      && (app.dbus.policies."org.kde.StatusNotifierWatcher" or null) == "talk"
    else
      !app.desktopIntegration.tray;

  mkAppPolicy =
    name: spec:
    let
      app = load name;
      allowedVideoDevices = spec.allowedVideoDevices or [ ];
      forbiddenMountFor = path: forbiddenMount path && !lib.elem path allowedVideoDevices;
      checks = {
        "${name}/clearEnv" = app.bubblewrap.clearEnv;
        "${name}/dbus" = app.dbus.enable;
        "${name}/noRawPipewire" = !app.bubblewrap.sockets.pipewire;
        "${name}/noForbiddenDbus" = !lib.any forbiddenDbus app.dbus.args;
        "${name}/noBroadKeyring" =
          !lib.any (argument: argument == "--talk=org.freedesktop.secrets") app.dbus.args;
        "${name}/noForbiddenMounts" = !lib.any forbiddenMountFor (mountStrings app);
        "${name}/hostFontconfig" = hasHostFontconfig app;
        "${name}/noSandboxFonts" = !app.fonts.enable;
        "${name}/privateTmp" = hasPrivateTmp app;
        "${name}/network" = networkCheck app spec.network;
        "${name}/x11" = app.bubblewrap.sockets.x11 == (spec.x11 or false);
        "${name}/media" = mediaCheck app (spec.media or false);
        "${name}/pulse" = app.bubblewrap.sockets.pulse == (spec.pulse or (spec.media or false));
        "${name}/mpris" = app.desktopIntegration.mpris == (spec.mpris or false);
        "${name}/notifications" = app.desktopIntegration.notifications == (spec.notifications or true);
        "${name}/tray" = trayCheck app (spec.tray or false);
        "${name}/browserpass" =
          (app.browserPermissions.browserpass or false) == (spec.browserpass or false);
        "${name}/personalFiles" =
          (app.browserPermissions.personalFiles or false) == (spec.personalFiles or false);
        "${name}/secretPortal" = secretPortalCheck app (spec.secretPortal or false);
      };
      extraChecks = lib.mapAttrs' (checkName: value: {
        name = "${name}/${checkName}";
        inherit value;
      }) (spec.extraChecks or { });
      duplicates = lib.attrNames (lib.intersectAttrs checks extraChecks);
    in
    if duplicates != [ ] then
      throw "duplicate nixpak policy checks for ${name}: ${lib.concatStringsSep ", " duplicates}"
    else
      checks // extraChecks;

  globalChecks =
    let
      paths = map (app: app.bubblewrap.bind.rw) apps;
      tmpPaths = map (
        bind:
        lib.findFirst (
          entry: builtins.isList entry && builtins.length entry == 2 && builtins.elem "/tmp" entry
        ) null bind
      ) paths;
    in
    {
      appTmpIsolation =
        lib.all (path: builtins.isList path && builtins.length path == 2) tmpPaths
        && lib.length (lib.unique (map builtins.head tmpPaths)) == builtins.length apps;
    };
in
{
  inherit
    lib
    appNames
    load
    mountStrings
    withoutSecretPortal
    mkAppPolicy
    globalChecks
    ;
}
