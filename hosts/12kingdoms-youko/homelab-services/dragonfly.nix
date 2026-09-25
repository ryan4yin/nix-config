{
  ...
}:
{
  # A single shared Redis-compatible server for the host, mirroring
  # `postgresql.nix`: services share it and separate logical databases.
  # Dragonfly is a Redis drop-in; Immich reaches it over loopback TCP via
  # `services.immich.redis.host`/`port` rather than its own unix socket.
  services.dragonflydb = {
    enable = true;
    bind = "127.0.0.1";
    port = 6379;
    # A cache/job-queue store, not a database: bound memory (bytes), but do NOT
    # enable cache_mode (LRU eviction could drop Immich's BullMQ job entries).
    maxMemory = 1073741824; # 1 GiB
  };
}
