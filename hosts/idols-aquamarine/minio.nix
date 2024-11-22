{config, ...}: let
  dataDir = ["/data/apps/minio/data"];
  configDir = "/data/apps/minio/config";
in {
  # https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/services/web-servers/minio.nix
  services.minio = {
    enable = true;
    browser = true; # Enable or disable access to web UI.

    inherit dataDir configDir;
    listenAddress = "127.0.0.1:9096";
    consoleAddress = "127.0.0.1:9097"; # Web UI
    region = "us-east-1"; # default to us-east-1, same as AWS S3.

    # File containing the MINIO_ROOT_USER, default is “minioadmin”, and MINIO_ROOT_PASSWORD (length >= 8), default is “minioadmin”;
    rootCredentialsFile = config.age.secrets."minio.env".path;
  };
}
