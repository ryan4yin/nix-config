{
  config,
  pkgs,
  lib,
  myvars,
  ...
}: let
  inherit (myvars) username;
in {
  # https://wiki.nixos.org/wiki/PostgreSQL
  # https://search.nixos.org/options?channel=unstable&query=services.postgresql.
  # https://www.postgresql.org/docs/
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    # https://www.postgresql.org/docs/16/jit.html
    # JIT compilation is beneficial primarily for long-running CPU-bound queries.
    # Frequently these will be analytical queries. For short queries the added overhead
    # of performing JIT compilation will often be higher than the time it can save.
    enableJIT = true;
    enableTCPIP = true;
    dataDir = "/data/apps/postgresql${config.services.postgresql.package.psqlSchema}";

    # Ensures that the specified databases exist.
    ensureDatabases = [
      "mytestdb" # for testing
      "openobserve"
      "juicefs"
    ];
    ensureUsers = [
      {
        name = "openobserve";
        ensureDBOwnership = true;
      }
      {
        name = "juicefs";
        ensureDBOwnership = true;
      }
    ];
    initdbArgs = [
      "--data-checksums"
      "--allow-group-access"
    ];

    extraPlugins = ps:
      with ps; [
        # postgis
        # pg_repack
      ];

    # https://www.postgresql.org/docs/16/runtime-config.html
    settings = {
      port = 5432;
      # connections
      max_connections = 100;

      # logging
      log_connections = true;
      log_statement = "all";
      logging_collector = true;
      log_disconnections = true;
      log_destination = lib.mkForce "syslog";

      # ssl
      ssl = true;
      ssl_cert_file = ../../certs/ecc-server.crt;
      ssl_key_file = config.age.secrets."certs/ecc-server.key".path;
      ssl_min_protocol_version = "TLSv1.3";
      ssl_ecdh_curve = "secp384r1";
      # Using custom DH parameters reduces the exposure
      # dhparam -out dhparams.pem 2048
      # ssl_dh_params_file = "";

      # memory
      shared_buffers = "128MB";
      huge_pages = "try";
    };

    identMap = ''
      # ArbitraryMapName systemUser DBUser
      superuser_map      root        postgres
      superuser_map      postgres    postgres
      superuser_map      ${username} postgres
      # Let other names login as themselves
      superuser_map      /^(.*)$     \1
    '';

    authentication = pkgs.lib.mkOverride 10 ''
      # type database DBuser origin-address auth-method

      # trust all localhost access
      host  all      all     127.0.0.1/32   trust
      host all       all     ::1/128        trust
    '';
    # initialScript =
    #   pkgs.writeText "backend-initScript" ''
    #   '';
  };

  services.prometheus.exporters.postgres = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = "9187";
    user = "postgres-exporter";
    group = "postgres-exporter";
    dataSourceName = "user=postgres database=postgres host=/run/postgresql sslmode=verify-full";
  };
}
