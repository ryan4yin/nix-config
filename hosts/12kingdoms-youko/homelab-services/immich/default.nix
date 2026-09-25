{
  ...
}:
let
  dataDir = "/data/apps/immich";
in
{
  services.immich = {
    enable = true;
    host = "127.0.0.1";
    port = 2283;
    mediaLocation = dataDir;

    # Reuse the host PostgreSQL 16 (postgresql.nix): the module adds pgvector +
    # vectorchord, sets shared_preload_libraries, and creates the immich
    # database and user. No separate database container.
    database = {
      enable = true;
      createDB = true;
    };

    # Use the shared Valkey instance (valkey.nix) instead of a private Redis.
    # With a non-unix-socket host the module passes REDIS_HOSTNAME/PORT.
    redis = {
      enable = false;
      host = "127.0.0.1";
      port = 6379;
    };

    machine-learning.enable = true;

    settings = {
      server.externalDomain = "https://immich.writefor.fun";
      # Skip Immich's outbound version checks.
      newVersionCheck.enabled = false;
    };

    # OTEL metrics, scraped by VictoriaMetrics on this host (see
    # monitoring/victoriametrics.nix). `all` collects host/api/io/repo/job.
    # Immich binds the metrics listeners to all interfaces (no bind-host
    # option), so they are LAN-reachable like node_exporter:9100; caddy does
    # not proxy them.
    environment = {
      IMMICH_API_METRICS_PORT = "8081";
      IMMICH_MICROSERVICES_METRICS_PORT = "8082";
      IMMICH_TELEMETRY_INCLUDE = "all";
    };
  };

  # mediaLocation is on the encrypted HDD and must stay non-world-readable; the
  # module only creates it when left at the default path.
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0750 immich immich -"
  ];

  # The ML model cache would otherwise live on the tmpfs root and be
  # re-downloaded after every reboot. Preserve it on the encrypted pool, owned
  # by the immich user so the service can write it.
  preservation.preserveAt."/persistent".directories = [
    {
      directory = "/var/cache/immich";
      user = "immich";
      mode = "0750";
    }
  ];

  # The media lives on /data (a separate mount), so order immich after it.
  systemd.services.immich-server.unitConfig.RequiresMountsFor = dataDir;
}
