{ pkgs, ... }:
{
  # WiVRn supplies the OpenXR runtime; xrizer translates OpenVR games.
  # The RTX 4090 is the only GPU, so the server needs no GPU environment of its own.
  services.wivrn = {
    enable = true;
    autoStart = false; # Start only when requested with just vr.

    # Use the unmodified nixpkgs package without installing its standalone GUI.
    # This reuses the upstream build; it does not trim Qt from its dependency closure.
    package = pkgs.symlinkJoin {
      name = "wivrn-cli-${pkgs.wivrn.version}";
      inherit (pkgs.wivrn) version meta;
      paths = [ pkgs.wivrn ];
      postBuild = ''
        rm "$out/bin/wivrn-dashboard" "$out/bin/.wivrn-dashboard-wrapped"
        rm "$out/share/applications/"*.desktop
        test -x "$out/bin/wivrn-server"
        test -x "$out/bin/wivrnctl"
        test ! -e "$out/bin/wivrn-dashboard"
        for entry in "$out/share/applications/"*.desktop; do
          test ! -e "$entry"
        done
      '';
    };

    # CAP_SYS_NICE for the server. WiVRn starts games in separate units, and an
    # already running Steam client keeps its own environment.
    highPriority = true;
    steam.importOXRRuntimes = true;
  };

  # Wait for the control interface used by wivrnctl before reporting success.
  systemd.user.services.wivrn.serviceConfig = {
    Type = "dbus";
    BusName = "io.github.wivrn.Server";
    TimeoutStartSec = "30s";
  };
}
