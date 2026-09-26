{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Jellyfin only reads media; it does not download it. The library is the
  # existing Transmission download tree on the (public) HDD, reached through
  # the shared `fileshare` group -- no Jellyfin-owned library directory.
  mediaDir = "/data/fileshare/public";

  # Public URL, written into network.xml so clients get a reachable address.
  domain = "jellyfin.writefor.fun";
in
{
  # Read access to the Transmission downloads (owned by group `fileshare`) and
  # to the GPU device nodes (`render`/`video`) for VA-API transcoding.
  users.users.jellyfin.extraGroups = [
    "fileshare"
    "render"
    "video"
  ];

  # VA-API needs Mesa's `radeonsi` driver under /run/opengl-driver. youko is a
  # headless server, so `hardware.graphics` is off by default and the driver
  # (and therefore VA-API) is missing.
  hardware.graphics.enable = true;

  services.jellyfin = {
    enable = true;

    # AMD Barceló iGPU: VA-API hardware transcoding. renderD128 is world
    # readable/writable, and the user is in `render`/`video` as well.
    hardwareAcceleration = {
      enable = true;
      type = "vaapi";
      device = "/dev/dri/renderD128";
    };

    # Make the Nix configuration the source of truth for encoding.xml, so
    # changes made in the web UI cannot silently drift from this file.
    forceEncodingConfig = true;
    transcoding = {
      enableToneMapping = true;
      # Use the iGPU for encoding too. Without this Jellyfin uses VA-API only
      # for decode/scale and falls back to the CPU `libx264`, which pins
      # several cores per stream.
      enableHardwareEncoding = true;
      # Vega (Barceló) decodes these.
      hardwareDecodingCodecs = {
        h264 = true;
        hevc = true;
        hevc10bit = true;
        mpeg2 = true;
        vc1 = true;
        vp8 = true;
        vp9 = true;
      };
      # H.264 hardware encode is always on; Vega's VCN also encodes HEVC
      # (verified with the bundled ffmpeg), but it has no AV1 encoder, so av1
      # is left off.
      hardwareEncodingCodecs.hevc = true;
    };
  };

  # The module creates /var/lib/jellyfin and /var/cache/jellyfin itself, both
  # on the preserved, encrypted nvme -- no extra tmpfiles rule is needed.

  # network.xml has no module option, so patch it on every start (idempotent;
  # only these two elements are touched):
  #  - KnownProxies: trust Caddy (127.0.0.1) so Jellyfin reads the real client
  #    IP from `X-Forwarded-For` (correct remote-access checks and per-IP
  #    login lockout instead of lumping everyone under the proxy's IP).
  #  - PublishedServerUriBySubnet: advertise the public URL to clients.
  #
  # `mkBefore` matters: the module's own preStart ends with `exit 0` once
  # encoding.xml already matches, so an `mkAfter` patch would only run on the
  # deploy that changes encoding settings. Running first is always safe.
  systemd.services.jellyfin.preStart = lib.mkBefore ''
    networkXml=${lib.escapeShellArg "${config.services.jellyfin.configDir}/network.xml"}
    if [ -f "$networkXml" ]; then
      ${lib.getExe pkgs.xmlstarlet} ed -L \
        -d '/NetworkConfiguration/KnownProxies/*' \
        -s '/NetworkConfiguration/KnownProxies' -t elem -n string -v '127.0.0.1' \
        -d '/NetworkConfiguration/PublishedServerUriBySubnet/*' \
        -s '/NetworkConfiguration/PublishedServerUriBySubnet' -t elem -n string -v ${lib.escapeShellArg "all=https://${domain}"} \
        "$networkXml"
    fi
  '';

  # Jellyfin apps discover the server over the LAN via UDP 7359, then talk to
  # TCP 8096 directly; the shared firewall already trusts the whole LAN.

  # The library is a separate, `nofail` mount; without this the unit can start
  # before it is mounted. The module's own RequiresMountsFor entries for
  # config/log/cache are merged with these list definitions.
  systemd.services.jellyfin.unitConfig.RequiresMountsFor = [ mediaDir ];
}
