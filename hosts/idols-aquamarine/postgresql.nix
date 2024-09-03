{
  config,
  pkgs,
  lib,
  myvars,
  ...
}: let
  inherit (myvars) username;

  user = "postgres"; # postgresql's default system user
  package = pkgs.postgresql_16;
  dataDir = "/data/apps/postgresql/${package.psqlSchema}";
in {
  # Create Directories
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0755 ${user} ${user}"
  ];

  # https://wiki.nixos.org/wiki/PostgreSQL
  # https://search.nixos.org/options?channel=unstable&query=services.postgresql.
  # https://www.postgresql.org/docs/
  services.postgresql = {
    enable = true;
    inherit package dataDir;
    # https://www.postgresql.org/docs/16/jit.html
    # JIT compilation is beneficial primarily for long-running CPU-bound queries.
    # Frequently these will be analytical queries. For short queries the added overhead
    # of performing JIT compilation will often be higher than the time it can save.
    enableJIT = true;
    enableTCPIP = true;

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
      ssl_cert_file = "${../../certs/ecc-server.crt}";
      ssl_key_file = config.age.secrets."postgres-ecc-server.key".path;
      ssl_min_protocol_version = "TLSv1.3";
      ssl_ecdh_curve = "secp384r1";
      # Using custom DH parameters reduces the exposure
      # dhparam -out dhparams.pem 2048
      # ssl_dh_params_file = "";

      # memory
      shared_buffers = "128MB";
      huge_pages = "try";
    };

    # allow root & myself can login via `psql -U postgres` without other aauthentication
    identMap = ''
      # ArbitraryMapName systemUser DBUser
      superuser_map      root                postgres
      superuser_map      postgres            postgres
      superuser_map      postgres-exporter   postgres
      superuser_map      ${username}         postgres
      # Let other names login as themselves
      superuser_map      /^(.*)$             \1
    '';

    # https://www.postgresql.org/docs/current/auth-pg-hba-conf.html
    authentication = lib.mkForce ''
      # TYPE  DATABASE        USER            ADDRESS                 METHOD   OPTIONS

      # "local" is for Unix domain socket connections only
      local   all             all                                     peer     map=superuser_map
      # IPv4 local connections:
      host    all             all             127.0.0.1/32            trust
      # IPv6 local connections:
      host    all             all             ::1/128                 trust
      # Allow replication connections from localhost, by a user with the
      # replication privilege.
      local   replication     all                                     trust
      host    replication     all             127.0.0.1/32            trust
      host    replication     all             ::1/128                 trust

      # Other Remote Access - allow access only the database with the same name as the user
      host    sameuser        all             0.0.0.0/0               scram-sha-256
    '';
    # initialScript =
    #   pkgs.writeText "backend-initScript" ''
    #   '';
  };

  services.prometheus.exporters.postgres = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 9187;
    user = "postgres-exporter";
    group = "postgres-exporter";
    dataSourceName = "user=postgres database=postgres host=/run/postgresql sslmode=verify-full";
  };
}
