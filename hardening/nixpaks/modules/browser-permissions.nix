# Shared browser capabilities. Network topology and application profiles are
# selected by the app; personal files, browserpass, Secret portal and media are explicit opt-ins.
{
  config,
  lib,
  sloth,
  ...
}:
let
  cfg = config.browserPermissions;
  passwordStore = sloth.concat' sloth.homeDir "/.local/share/password-store";
in
{
  imports = [ ./desktop-base.nix ];
  options.browserPermissions = {
    media = lib.mkEnableOption "audio playback/recording, camera and desktop screen sharing";
    personalFiles = lib.mkEnableOption "personal Documents, media directories and Trash";
    browserpass = lib.mkEnableOption "browserpass access to the password store and GPG agent";
    secretPortal = lib.mkEnableOption "the app-scoped Secret portal for v12 cookie encryption";
  };
  config = {
    portalGroups = {
      fileChooser = true;
      openUri = true;
      notifications = true;
      screenCast = cfg.media;
      camera = cfg.media;
      print = true;
      inhibit = cfg.media;
      inputMethod = true;
      secret = cfg.secretPortal;
    };
    desktopIntegration = {
      notifications = true;
      mpris = cfg.media;
      accessibility = true;
    };
    bubblewrap = {
      sockets.pulse = cfg.media;
      bind.rw = [
        sloth.xdgDownloadDir
      ]
      ++ lib.optionals cfg.personalFiles [
        sloth.xdgDocumentsDir
        sloth.xdgMusicDir
        sloth.xdgVideosDir
        sloth.xdgPicturesDir
        (sloth.mkdir (sloth.concat' sloth.homeDir "/.local/share/Trash"))
      ];
      bind.ro = [
        (sloth.concat' sloth.homeDir "/.config/mimeapps.list")
        (sloth.concat' sloth.homeDir "/.config/user-dirs.dirs")
        (sloth.concat' sloth.homeDir "/.pki/nssdb")
      ]
      ++ lib.optionals cfg.browserpass [
        "/etc/gnupg"
        (sloth.concat' sloth.homeDir "/.gnupg")
        passwordStore
        (sloth.concat' sloth.runtimeDir "/gnupg")
      ];
      env = lib.optionalAttrs cfg.browserpass { PASSWORD_STORE_DIR = passwordStore; };
    };
  };
}
