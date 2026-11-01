{
  lib,
  remmina,
  mkNixPak,
  buildEnv,
  makeDesktopItem,
  runCommandLocal,
  ...
}:
let
  appId = "org.remmina.Remmina";
  wrapped = mkNixPak {
    config = {
      imports = [ ./modules/remote-desktop-policy.nix ];
      app = {
        package = remmina;
        binPath = "bin/remmina";
      };
      flatpak = { inherit appId; };
      # Preserve the SSH Tunnel tab used for localhost VNC access.
      remoteDesktop.sshAgent = true;
    };
  };
  exe = lib.getExe wrapped.config.script;
  assets = runCommandLocal "remmina-desktop-assets" { } ''
    mkdir -p $out/share
    ln -s ${remmina}/share/icons $out/share/icons
  '';
in
buildEnv {
  inherit (wrapped.config.script) name passthru;
  meta = wrapped.config.script.meta // {
    mainProgram = "remmina";
  };
  paths = [
    wrapped.config.script
    assets
    (makeDesktopItem {
      name = appId;
      desktopName = "Remmina";
      genericName = "Remote Desktop Client";
      comment = "Connect to RDP, VNC, SPICE and SSH sessions";
      exec = "${exe} %U";
      icon = appId;
      terminal = false;
      startupNotify = true;
      startupWMClass = appId;
      categories = [
        "GTK"
        "Network"
      ];
      mimeTypes = [
        "application/x-remmina"
        "x-scheme-handler/rdp"
        "x-scheme-handler/spice"
        "x-scheme-handler/vnc"
        "x-scheme-handler/ssh"
        "x-scheme-handler/remmina"
      ];
      extraConfig.X-Flatpak = appId;
    })
  ];
}
