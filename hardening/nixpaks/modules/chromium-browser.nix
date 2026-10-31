# Shared Chromium-family wrapper. The upstream package still supplies Chromium's
# own sandbox; nixpak adds filesystem, D-Bus and network boundaries.
{
  lib,
  mkNixPak,
  buildEnv,
  makeDesktopItem,
  runCommandLocal,
  makeWrapper,
  ...
}:
{
  package,
  appId,
  profile,
  command,
  desktopName,
  desktopFile ? command,
  browserpass ? false,
  media ? false,
  secretPortal ? false,
  hostLoopback ? false,
  personalFiles ? false,
  privateWindowFlag ? "--incognito",
}:
let
  # Chromium uses its unprivileged user-namespace sandbox inside nixpak.
  # Do not pass --no-sandbox or --disable-setuid-sandbox: renderer Seccomp/NNP
  # remains active without either flag, and the latter triggers an infobar.
  # Chromium 156 leaves PipeWire camera capture disabled by default. Enable it
  # for media-enabled browsers so camera access uses the portal's FD without raw video devices.
  # Keep the Wayland feature from nixpkgs: the last --enable-features wins.
  enabledFeatures = lib.concatStringsSep "," (
    [ "WaylandWindowDecorations" ]
    ++ lib.optional media "WebRtcPipeWireCamera"
    ++ lib.optional secretPortal "SecretPortalKeyProviderUseForEncryption"
  );
  usernsPackage =
    runCommandLocal "${package.name}-userns"
      {
        nativeBuildInputs = [ makeWrapper ];
      }
      ''
        mkdir -p $out/bin
        makeWrapper ${package}/bin/${command} $out/bin/${command} \
          --add-flags "--enable-features=${enabledFeatures}"
      '';
  wrapped = mkNixPak {
    config =
      { sloth, ... }:
      {
        imports = [
          ./browser-permissions.nix
          ./network.nix
        ];
        app = {
          package = usernsPackage;
          binPath = "bin/${command}";
        };
        flatpak = { inherit appId; };
        # Firefox and Chromium share the host network for local development.
        # Work Chrome and the other browsers keep pasta's isolated loopback.
        pasta.enable = lib.mkForce (!hostLoopback);
        pasta.mode = "isolate";
        browserPermissions = {
          inherit
            browserpass
            personalFiles
            media
            secretPortal
            ;
        };
        bubblewrap.bind.rw = [
          (sloth.mkdir (sloth.concat' sloth.homeDir "/.config/${profile}"))
        ];
      };
  };
  exe = "${wrapped.config.script}/bin/${command}";
  # Only copy desktop assets: including the original package in buildEnv would
  # expose alternate executable names that bypass the wrapper.
  assets = runCommandLocal "${command}-desktop-assets" { } ''
    mkdir -p $out/share
    for directory in icons pixmaps; do
      if [ -d ${package}/share/$directory ]; then
        ln -s ${package}/share/$directory $out/share/$directory
      fi
    done
  '';
in
buildEnv {
  inherit (wrapped.config.script) name meta passthru;
  paths = [
    wrapped.config.script
    assets
    (makeDesktopItem {
      name = appId;
      inherit desktopName;
      genericName = "Web Browser";
      exec = "${exe} %U";
      icon = desktopFile;
      terminal = false;
      startupNotify = true;
      categories = [
        "Network"
        "WebBrowser"
      ];
      mimeTypes = [
        "text/html"
        "application/xhtml+xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
      actions = {
        new-window = {
          name = "New Window";
          exec = "${exe} --new-window %U";
        };
        new-private-window = {
          name = "New Private Window";
          exec = "${exe} ${privateWindowFlag} %U";
        };
      };
      extraConfig.X-Flatpak = appId;
    })
  ];
}
