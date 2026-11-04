# Shared browser capabilities. Network topology and application profiles are
# selected by the app; personal files, browserpass, Secret portal, media and
# FIDO2 security-key access are explicit opt-ins.
{
  config,
  lib,
  pkgs,
  sloth,
  ...
}:
let
  cfg = config.browserPermissions;
  passwordStore = sloth.concat' sloth.homeDir "/.local/share/password-store";
  # Maintained by the host udev rules in ../default.nix.
  fidoDir = "/dev/fido-hidraw";
  fidoBwrap = import ./fido-bwrap.nix { inherit pkgs fidoDir; };
in
{
  imports = [ ./desktop-base.nix ];
  options.browserPermissions = {
    media = lib.mkEnableOption "audio playback/recording, camera and desktop screen sharing";
    personalFiles = lib.mkEnableOption "personal Documents, media directories and Trash";
    browserpass = lib.mkEnableOption "browserpass access to the password store and GPG agent";
    secretPortal = lib.mkEnableOption "the app-scoped Secret portal for v12 cookie encryption";
    fido2 = lib.mkEnableOption "FIDO2 security-key (CanoKey/YubiKey) WebAuthn and passkey access";
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
      package = lib.mkIf cfg.fido2 fidoBwrap;
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
      ]
      # libudev enumeration and hotplug: hidraw class links (device directories
      # come from desktop-base/GPU sysfs binds), the udev database without which
      # devnode-backed devices count as uninitialized, and the control socket
      # whose presence enables the udev monitor. Root owns the socket.
      ++ lib.optionals cfg.fido2 [
        "/sys/class/hidraw"
        "/run/udev/data"
        "/run/udev/control"
      ];
      bind.dev = lib.optional cfg.fido2 fidoDir;
      env = lib.optionalAttrs cfg.browserpass { PASSWORD_STORE_DIR = passwordStore; };
    };
  };
}
