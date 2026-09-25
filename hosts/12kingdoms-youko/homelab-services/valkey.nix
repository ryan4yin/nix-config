{
  pkgs,
  ...
}:
{
  # Shared Redis-compatible cache for the host; Immich points here over loopback.
  # Valkey (BSD Redis fork), not Dragonfly: the latter rejects BullMQ's dynamic-key Lua scripts.
  # maxmemory + noeviction: bound memory, and fail a full queue's writes instead of dropping jobs.
  services.redis.package = pkgs.valkey;
  services.redis.servers.shared = {
    enable = true;
    bind = "127.0.0.1";
    port = 6379;
    settings = {
      maxmemory = "4gb";
      "maxmemory-policy" = "noeviction";
    };
  };
}
