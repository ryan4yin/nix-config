{
  config,
  pkgs-small,
  ...
}:
{
  # The service module comes from the default nixpkgs (services.rustfs);
  # pkgs-small (instantiated in outputs/default.nix) only supplies the newer
  # package. The module creates the rustfs user/group, the data volume via
  # tmpfiles, and a hardened systemd unit.
  services.rustfs = {
    enable = true;
    package = pkgs-small.rustfs;
    settings = {
      # New directory; the old MinIO tree at /data/apps/minio is kept as a
      # rollback snapshot and was carried over via an S3-level copy.
      RUSTFS_VOLUMES = "/data/apps/rustfs";
      # Loopback only; caddy terminates TLS and reverse-proxies 443 -> 9000/9001.
      RUSTFS_ADDRESS = "127.0.0.1:9000";
      RUSTFS_CONSOLE_ADDRESS = "127.0.0.1:9001";
      RUSTFS_CONSOLE_ENABLE = "true";
      # Sign/presign against the public hostname, since the public port (443)
      # differs from the internal one (9000).
      RUSTFS_SERVER_DOMAINS = "s3.writefor.fun";
      RUST_LOG = "info";
    };
    # Root credentials (access key = root "user", secret key = password), as a
    # dotenv secret with RUSTFS_ACCESS_KEY / RUSTFS_SECRET_KEY.
    environmentFile = config.age.secrets."rustfs.env".path;
  };

  # The data volume lives on the encrypted HDD subvolume; wait for its mount.
  systemd.services.rustfs.unitConfig.RequiresMountsFor = "/data/apps";
}
