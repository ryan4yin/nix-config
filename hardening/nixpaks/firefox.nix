# Refer:
# - Flatpak manifest's docs:
#   - https://docs.flatpak.org/en/latest/manifests.html
#   - https://docs.flatpak.org/en/latest/sandbox-permissions.html
# - Firefox's flatpak manifest: https://hg.mozilla.org/mozilla-central/file/tip/taskcluster/docker/firefox-flatpak/runme.sh#l151
{
  lib,
  firefox,
  mkNixPak,
  buildEnv,
  makeDesktopItem,
  ...
}:

let
  appId = "org.mozilla.firefox";
  wrapped = mkNixPak {
    config =
      {
        config,
        sloth,
        ...
      }:
      let
        passwordStore = sloth.concat' sloth.homeDir "/.local/share/password-store";
      in
      {
        app = {
          package = firefox;
          binPath = "bin/firefox";
        };
        flatpak.appId = appId;

        imports = [
          ./modules/gui-base.nix
          ./modules/network.nix
          ./modules/custom-policy.nix
        ];

        # Firefox keeps the host network: local development servers and the
        # mihomo controller live on 127.0.0.1, and pasta's isolated loopback
        # would hide them. The other sandboxed apps do not need host loopback.
        pasta.enable = lib.mkForce false;

        bubblewrap = {
          # To trace all the home files Firefox accesses, you can use the following nushell command:
          #   just trace-access firefox
          # See the Justfile in the root of this repository for more information.
          bind.rw = [
            # given the read write permission to the following directories.
            # NOTE: sloth.mkdir is used to create the directory if it does not exist!
            (sloth.mkdir (sloth.concat' sloth.homeDir "/.mozilla"))

            # MPRIS artwork: Firefox writes covers here and advertises the same
            # path over MPRIS. Without this bind it lands under the sandboxed
            # XDG_DATA_HOME and Noctalia (outside) cannot read it.
            (sloth.mkdir (sloth.concat' sloth.homeDir "/.local/share/firefox-mpris"))

            # Files deleted from Firefox go to the real trash instead of a
            # private one under the sandboxed XDG_DATA_HOME.
            (sloth.mkdir (sloth.concat' sloth.homeDir "/.local/share/Trash"))

            sloth.xdgDocumentsDir
            sloth.xdgDownloadDir
            sloth.xdgMusicDir
            sloth.xdgVideosDir
            sloth.xdgPicturesDir
          ];
          bind.ro = [
            "/sys/bus/pci"
            [
              "${config.app.package}/lib/firefox"
              "/app/etc/firefox"
            ]

            # ================ for browserpass extension ===============================
            "/etc/gnupg"
            (sloth.concat' sloth.homeDir "/.gnupg") # gpg's config
            passwordStore # my secrets
            (sloth.concat' sloth.runtimeDir "/gnupg") # for access gpg-agent socket

            # Match the host's default-app associations and XDG user dirs.
            (sloth.concat' sloth.homeDir "/.config/mimeapps.list")
            (sloth.concat' sloth.homeDir "/.config/user-dirs.dirs")

            # Shared NSS client-certificate store (imported outside Firefox).
            (sloth.concat' sloth.homeDir "/.pki/nssdb")

            # dconf settings. Not verified as needed; candidate for removal.
            (sloth.concat' sloth.xdgConfigHome "/dconf")
          ];
          # browserpass looks for the store here, not at pass's default path.
          env.PASSWORD_STORE_DIR = passwordStore;
        };
      };
  };
  exePath = lib.getExe wrapped.config.script;
in
buildEnv {
  inherit (wrapped.config.script) name meta passthru;
  paths = [
    wrapped.config.script
    (makeDesktopItem {
      name = appId;
      desktopName = "Firefox";
      genericName = "Firefox Boxed";
      comment = "Firefox Browser";
      exec = "${exePath} %U";
      terminal = false;
      icon = "firefox";
      startupNotify = true;
      startupWMClass = "firefox";
      type = "Application";
      categories = [
        "Network"
        "WebBrowser"
      ];
      mimeTypes = [
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "application/vnd.mozilla.xul+xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];

      actions = {
        new-private-window = {
          name = "New Private Window";
          exec = "${exePath} --private-window %U";
        };
        new-window = {
          name = "New Window";
          exec = "${exePath} --new-window %U";
        };
        profile-manager-window = {
          name = "Profile Manager";
          exec = "${exePath} --ProfileManager";
        };
      };

      extraConfig = {
        X-Flatpak = appId;
      };
    })
  ];
}
