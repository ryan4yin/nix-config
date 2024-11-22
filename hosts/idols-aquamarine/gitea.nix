{pkgs, ...}: {
  # https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/services/misc/gitea.nix
  services.gitea = {
    enable = true;
    user = "gitea";
    group = "gitea";
    stateDir = "/data/apps/gitea";
    appName = "Ryan Yin's Gitea Service";
    lfs.enable = true;
    # Enable a timer that runs gitea dump to generate backup-files of the current gitea database and repositories.
    dump = {
      enable = false;
      interval = "hourly";
      file = "gitea-dump";
      type = "tar.zst";
    };
    # Path to a file containing the SMTP password.
    # mailerPasswordFile = "";
    settings = {
      server = {
        SSH_PORT = 2222;
        PROTOCOL = "http";
        HTTP_PORT = 3301;
        HTTP_ADDR = "127.0.0.1";
        DOMAIN = "git.writefor.fun";
        ROOT_URL = "https://git.writefor.fun/";
      };
      # one of "Trace", "Debug", "Info", "Warn", "Error", "Critical"
      log.LEVEL = "Info";
      # Marks session cookies as "secure" as a hint for browsers to only send them via HTTPS.
      session.COOKIE_SECURE = true;
      # NOTE: The first registered user will be the administrator,
      # so this parameter should NOT be set before the first user registers!
      service.DISABLE_REGISTRATION = true;
      # https://docs.gitea.com/administration/config-cheat-sheet#security-security
      security = {
        LOGIN_REMEMBER_DAYS = 31;
        PASSWORD_HASH_ALGO = "scrypt";
        MIN_PASSWORD_LENGTH = 10;
      };

      # "cron.sync_external_users" = {
      #   RUN_AT_START = true;
      #   SCHEDULE = "@every 24h";
      #   UPDATE_EXISTING = true;
      # };
      mailer = {
        ENABLED = true;
        MAILER_TYPE = "sendmail";
        FROM = "do-not-reply@writefor.fun";
        SENDMAIL_PATH = "${pkgs.system-sendmail}/bin/sendmail";
      };
      other = {
        SHOW_FOOTER_VERSION = false;
      };
    };
    database = {
      type = "sqlite3";
      # create a local database automatically.
      createDatabase = true;
    };
  };

  # services.gitea-actions-runner.instances."default" = {
  #   enable = true;
  #   name = "default";
  #   labels = [
  #     # provide a debian base with nodejs for actions
  #     "debian-latest:docker://node:18-bullseye"
  #     # fake the ubuntu name, because node provides no ubuntu builds
  #     "ubuntu-latest:docker://node:18-bullseye"
  #     # provide native execution on the host
  #     "native:host"
  #   ];
  #   gitea = "http://git.writefor.fun";
  #   # Path to an environment file,
  #   # containing the TOKEN environment variable,
  #   # that holds a token to register at the configured Gitea instance.
  #   tokenFile = "xxx"; # use agenix for secrets.
  #   # Configuration for act_runner daemon.
  #   # For an example configuration, see:
  #   #  https://gitea.com/gitea/act_runner/src/branch/main/internal/pkg/config/config.example.yaml
  #   settings = {};
  #   # List of packages, that are available to actions,
  #   # when the runner is configured with a host execution label.
  #   hostPackages = with pkgs; [
  #     bash
  #     coreutils
  #     curl
  #     gawk
  #     gitMinimal
  #     gnused
  #     nodejs
  #     wget
  #   ];
  # };
}
