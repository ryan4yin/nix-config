{ pkgs, ... }:
{
  # WiVRn supplies the OpenXR runtime; xrizer translates OpenVR games.
  # The server uses the host GPU environment from hardware-nvidia.nix.
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

    # CAP_SYS_NICE for the server. Games need their own PRIME offload: WiVRn
    # starts them in separate units, which do not inherit this environment.
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
