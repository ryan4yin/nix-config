{
  config,
  attic,
  ...
}: {
  #=====================================================
  #
  # Attic
  #
  # A self-hostable Nix Binary Cache server
  # backed by an S3-compatible storage provider
  #
  # https://docs.attic.rs/tutorial.html
  #
  #=====================================================

  imports = [
    attic.nixosModules.atticd
  ];

  # Self-Hosted Nix Cache Server
  # https://github.com/zhaofengli/attic
  #
  # The first thing to do after setting up the server is:
  # 1. Generate a admin token on the server via command:
  #    `sudo atticd-atticadm make-token --sub "admin-1" --validity "2y" --pull "*" --push "*"  --delete "*" --create-cache "*" --configure-cache "*"  --configure-cache-retention "*"  --destroy-cache "*"`
  # 2. Login at the desktop via command:
  #    `attic login central http://attic.writefor.fun <TOKEN>`
  # 3. Create a new cache via command:
  #    `attic cache create rk3588`
  #    `attic use cache rk3588`
  # 4. Push Caches to the cache server via:
  #    it's similar to cachix, related docs:
  #    https://docs.attic.rs/reference/attic-cli.html
  #    https://docs.cachix.org/pushing#pushing
  services.atticd = {
    enable = true;

    # Replace with absolute path to your credentials file
    # The HS256 JWT secret can be generated with the openssl:
    #   openssl rand 64 | base64 -w0
    #
    # Content:
    #   ATTIC_SERVER_TOKEN_HS256_SECRET_BASE64="output from openssl"
    credentialsFile = config.age.secrets."attic-nix-cache-server.env".path;

    settings = {
      listen = "[::]:8888";

      # Data chunking
      #
      # Warning: If you change any of the values here, it will be
      # difficult to reuse existing chunks for newly-uploaded NARs
      # since the cutpoints will be different. As a result, the
      # deduplication ratio will suffer for a while after the change.
      chunking = {
        # The minimum NAR size to trigger chunking
        #
        # If 0, chunking is disabled entirely for newly-uploaded NARs.
        # If 1, all NARs are chunked.
        nar-size-threshold = 64 * 1024; # 64 KiB

        # The preferred minimum size of a chunk, in bytes
        min-size = 16 * 1024; # 16 KiB

        # The preferred average size of a chunk, in bytes
        avg-size = 64 * 1024; # 64 KiB

        # The preferred maximum size of a chunk, in bytes
        max-size = 256 * 1024; # 256 KiB
      };
    };
  };
}
