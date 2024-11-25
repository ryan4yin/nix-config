{config, ...}: let
  user = "sftpgo";
  dataDir = "/data/apps/sftpgo";
in {
  # Read SFTPGO_DEFAULT_ADMIN_USERNAME and SFTPGO_DEFAULT_ADMIN_PASSWORD from a file
  systemd.services.sftpgo.serviceConfig.EnvironmentFile = config.age.secrets."sftpgo.env".path;

  # Create Directories
  # https://www.freedesktop.org/software/systemd/man/latest/tmpfiles.d.html#Type
  systemd.tmpfiles.rules = [
    "d ${dataDir} 0755 ${user} ${user}"
  ];

  services.sftpgo = {
    enable = true;
    inherit user dataDir;
    extraArgs = [
      "--log-level"
      "info"
    ];
    # https://github.com/drakkan/sftpgo/blob/2.5.x/docs/full-configuration.md
    settings = {
      common = {
        # Auto-blocking policy for SFTPGo and thus helps to prevent DoS (Denial of Service) and brute force password guessing.
        defender = {
          enable = true;
        };
      };
      # Where to store stfpgo's data
      data_provider = {
        driver = "sqlite";
        name = "sftpgo.db";
        password_hashing = {
          algo = "argon2id";
          # options for argon2id hashing algorithm.
          # The memory and iterations parameters control the computational cost of hashing the password.
          argon2_options = {
            memory = 65536; # KiB
            iterations = 2; # The number of iterations over the memory.
            parallelism = 2; # The number of threads (or lanes) used by the algorithm.
          };
        };
        password_validation = {
          # What Entropy Value Should I Use?
          # somewhere in the 50-70 range seems "reasonable".
          # https://github.com/wagslane/go-password-validator#what-entropy-value-should-i-use
          admins.min_entropy = 60;
          users.min_entropy = 60;
        };
        # Cache passwords in memory to avoid hashing the same password multiple times(it costs).
        password_caching = true;
        # create the default admin user via environment variables
        # SFTPGO_DEFAULT_ADMIN_USERNAME and SFTPGO_DEFAULT_ADMIN_PASSWORD
        create_default_admin = true;
      };

      # WebDAV is a popular protocol for file sharing, better than CIFS/SMB, NFS, etc.
      # it's save to use WebDAV over HTTPS on public networks.
      webdavd.bindings = [
        {
          address = "127.0.0.1";
          port = 3303;
        }
      ];
      # HTTP Server provides a simple web interface to manage the server.
      httpd.bindings = [
        {
          address = "127.0.0.1";
          enable_https = false;
          port = 3302;
          client_ip_proxy_header = "X-Forwarded-For";
          # a basic built-in web interface that allows you to manage users,
          # virtual folders, admins and connections.
          # url: http://127.0.0.1:8080/web/admin
          enable_web_admin = true;
          # A basic front-end web interface for your users.
          # It allows end-users to browse and manage their files and change their credentials.
          enable_web_client = true;
          enable_rest_api = true;
        }
      ];
      # prometheus metrics
      telemetry = {
        bind_port = 10000;
        bind_address = "0.0.0.0";
        # auth_user_file = "";
      };
      # multi-factor authentication settings
      mfa.totp = [
        {
          # Unique configuration name, not visible to the authentication apps.
          # Should not to be changed after the first user has been created.
          name = "SFTPGo";
          # Name of the issuing Organization/Company
          issuer = "SFTPGo";
          # Algorithm to use for HMAC
          # Currently Google Authenticator app on iPhone seems to only support sha1
          algo = "sha1";
        }
      ];
      # SMTP configuration enables SFTPGo email sending capabilities
      # smtp = {};
    };
  };
}
