{
  lib,
  load,
  mkAppPolicy,
  withoutSecretPortal,
  ...
}:
let
  firefox = load "firefox";
  chromium = load "chromium";
in
mkAppPolicy "firefox" {
  network = "host";
  media = true;
  mpris = true;
  notifications = true;
  personalFiles = true;
  browserpass = true;
  secretPortal = false;
  extraChecks = {
    capabilitiesMatchChromium =
      firefox.browserPermissions.media == chromium.browserPermissions.media
      && firefox.browserPermissions.personalFiles == chromium.browserPermissions.personalFiles
      && firefox.browserPermissions.browserpass == chromium.browserPermissions.browserpass
      &&
        (removeAttrs firefox.portalGroups [ "secret" ]) == (removeAttrs chromium.portalGroups [ "secret" ])
      && firefox.desktopIntegration == chromium.desktopIntegration;
    portalCallsMatchChromium =
      withoutSecretPortal firefox.dbus.rules.call == withoutSecretPortal chromium.dbus.rules.call;
  };
}
