# Evaluate with the same pkgs/mkNixPak as the wrappers. Returns true or identifies
# the violated policy boundary; does not build or launch an application.
{ pkgs, mkNixPak }:
let
  inherit (pkgs) lib;
  load = name: (pkgs.callPackage (../nixpaks + "/${name}.nix") { inherit mkNixPak; }).config;
  firefox = load "firefox";
  chromium = load "chromium";
  chrome = load "google-chrome";
  restrictedBrowsers = map load [
    "brave-origin"
    "microsoft-edge"
  ];
  chromiumFamily = map load [
    "chromium"
    "google-chrome"
    "brave-origin"
    "microsoft-edge"
  ];
  browsers = map load [
    "firefox"
    "chromium"
    "google-chrome"
    "brave-origin"
    "microsoft-edge"
  ];
  nonBrowserApps = map load [
    "qq"
    "telegram-desktop"
    "zoom"
    "wechat"
  ];
  browserAndChatApps =
    browsers
    ++ map load [
      "qq"
      "telegram-desktop"
    ];
  apps = browsers ++ nonBrowserApps;
  # Inspect effective proxy arguments, not just capability switches: an extra
  # direct service grant could otherwise bypass a disabled portal group.
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
  mountStrings =
    app: builtins.filter builtins.isString (lib.flatten (with app.bubblewrap.bind; rw ++ ro ++ dev));
  forbiddenMount =
    path:
    path == "/dev"
    || lib.hasPrefix "/dev/video" path
    || lib.hasPrefix "/dev/bus/usb" path
    || path == "/run/dbus"
    || path == "/run/dbus/system_bus_socket";
  checks = {
    personalBrowserCapabilitiesMatch =
      firefox.browserPermissions.media == chromium.browserPermissions.media
      && firefox.browserPermissions.personalFiles == chromium.browserPermissions.personalFiles
      && firefox.browserPermissions.browserpass == chromium.browserPermissions.browserpass
      &&
        (removeAttrs firefox.portalGroups [ "secret" ]) == (removeAttrs chromium.portalGroups [ "secret" ])
      && firefox.desktopIntegration == chromium.desktopIntegration;
    personalBrowserPortalCallsMatch =
      withoutSecretPortal firefox.dbus.rules.call == withoutSecretPortal chromium.dbus.rules.call;
    personalBrowserHostLoopback = lib.all (app: app.bubblewrap.network && !app.pasta.enable) [
      firefox
      chromium
    ];
    workBrowserIsolatedLoopback =
      chrome.bubblewrap.network
      && chrome.pasta.enable
      && chrome.pasta.mode == "isolate"
      && lib.elem "--no-map-gw" chrome.pasta.args;
    workBrowserMedia =
      chrome.portalGroups.camera
      && chrome.portalGroups.screenCast
      && chrome.bubblewrap.sockets.pulse
      && chrome.gpu.enable
      && lib.elem "--call=org.freedesktop.portal.Desktop=org.freedesktop.portal.Camera.OpenPipeWireRemote@/org/freedesktop/portal/desktop" chrome.dbus.args
      && lib.elem "--call=org.freedesktop.portal.Desktop=org.freedesktop.portal.ScreenCast.OpenPipeWireRemote@/org/freedesktop/portal/desktop" chrome.dbus.args;
    secretPortalScope =
      lib.all (
        app:
        app.browserPermissions.secretPortal
        && lib.any (
          arg:
          arg
          == "--call=org.freedesktop.portal.Desktop=org.freedesktop.portal.Secret.RetrieveSecret@/org/freedesktop/portal/desktop"
        ) app.dbus.args
        && !lib.any (arg: arg == "--talk=org.freedesktop.secrets") app.dbus.args
      ) chromiumFamily
      && !firefox.browserPermissions.secretPortal
      && lib.all (
        app:
        !(app.browserPermissions.secretPortal or false)
        && !lib.any (arg: lib.hasInfix "org.freedesktop.portal.Secret" arg) app.dbus.args
      ) nonBrowserApps;
    mediaScope =
      lib.all
        (
          app:
          app.browserPermissions.media
          && app.bubblewrap.sockets.pulse
          && app.portalGroups.camera
          && app.portalGroups.screenCast
        )
        [
          firefox
          chromium
          chrome
        ];
    restrictedBrowserMedia = lib.all (
      app:
      !app.browserPermissions.media
      && !app.bubblewrap.sockets.pulse
      && !app.bubblewrap.sockets.pipewire
      && !app.portalGroups.camera
      && !app.portalGroups.screenCast
      && !app.desktopIntegration.mpris
      && !lib.any (
        arg:
        lib.hasInfix "org.freedesktop.portal.Camera" arg
        || lib.hasInfix "org.freedesktop.portal.ScreenCast" arg
        || lib.hasInfix "org.mpris.MediaPlayer2" arg
      ) app.dbus.args
      && !lib.any (path: lib.hasPrefix "/dev/snd" path) (mountStrings app)
    ) restrictedBrowsers;
    personalFileScope =
      firefox.browserPermissions.personalFiles
      && chromium.browserPermissions.personalFiles
      && !chrome.browserPermissions.personalFiles;
    browserpassScope =
      lib.all (app: app.browserPermissions.browserpass) [
        firefox
        chromium
        chrome
      ]
      && lib.all (app: !app.browserPermissions.browserpass) (
        map load [
          "brave-origin"
          "microsoft-edge"
        ]
      );
    deniedServices = lib.all (app: !lib.any forbiddenDbus app.dbus.args) apps;
    noBroadKeyring = lib.all (
      app: !lib.any (arg: arg == "--talk=org.freedesktop.secrets") app.dbus.args
    ) apps;
    deniedDevicesAndSystemBus = lib.all (app: !lib.any forbiddenMount (mountStrings app)) apps;
    filteredEnvironmentAndMedia = lib.all (
      app:
      app.bubblewrap.clearEnv
      && app.dbus.enable
      && !app.bubblewrap.sockets.pipewire
      && !app.bubblewrap.sockets.x11
    ) browserAndChatApps;
  };
in
lib.all (name: checks.${name} || throw "nixpak policy check failed: ${name}") (
  builtins.attrNames checks
)
