{
  # https://github.com/NixOS/nixpkgs/blob/nixos-23.11/nixos/modules/services/monitoring/uptime-kuma.nix
  services.uptime-kuma = {
    enable = true;
    # https://github.com/louislam/uptime-kuma/wiki/Environment-Variables
    settings = {
      # this assumes a reverse proxy to be set, uptime-kuma will only listen on localhost
      "UPTIME_KUMA_HOST" = "127.0.0.1";
      "UPTIME_KUMA_PORT" =  3001;
      "DATA_DIR" =  "/data/uptime-kuma";
    };
  };
}
