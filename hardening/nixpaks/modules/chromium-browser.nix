# Chromium-family wrapper: nixpak adds filesystem, D-Bus and network boundaries;
# the upstream Chromium renderer sandbox remains enabled.
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
  # Chromium 156 disables PipeWire camera capture by default; media apps need
  # the portal FD path instead of raw video devices.
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
        # Firefox/Chromium need host loopback for local services; Chrome and the rest use pasta.
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
  # Copy desktop assets only; the full package would expose unwrapped binaries.
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
