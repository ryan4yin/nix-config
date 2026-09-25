{
  ...
}:
let
  # Jellyfin only reads media; it does not download it. The library is the
  # existing Transmission download tree on the (public) HDD, reached through
  # the shared `fileshare` group -- no Jellyfin-owned library directory.
  mediaDir = "/data/fileshare/public";
in
{
  # Read access to the Transmission downloads (owned by group `fileshare`).
  # Jellyfin writes nothing here; transcodes go to the module's cacheDir.
  users.users.jellyfin.extraGroups = [ "fileshare" ];

  # VA-API needs Mesa's `radeonsi` driver under /run/opengl-driver. youko is a
  # headless server, so `hardware.graphics` is off by default and the driver
  # (and therefore VA-API) is missing.
  hardware.graphics.enable = true;

  services.jellyfin = {
    enable = true;

    # AMD Barceló iGPU: VA-API hardware transcoding. renderD128 is world
    # readable/writable, so only DeviceAllow (set by the module) is needed.
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
      # Vega (Barceló) decodes these; h264 encoding is always enabled and
      # Vega has no HEVC encoder, so hardwareEncodingCodecs stays at default.
      hardwareDecodingCodecs = {
        h264 = true;
        hevc = true;
        hevc10bit = true;
        mpeg2 = true;
        vc1 = true;
        vp8 = true;
        vp9 = true;
      };
    };
  };

  # The module creates /var/lib/jellyfin and /var/cache/jellyfin itself, both
  # on the preserved, encrypted nvme -- no extra tmpfiles rule is needed.

  # The library is a separate, `nofail` mount; without this the unit can start
  # before it is mounted. The module's own RequiresMountsFor entries for
  # config/log/cache are merged with these list definitions.
  systemd.services.jellyfin.unitConfig.RequiresMountsFor = [ mediaDir ];
}
