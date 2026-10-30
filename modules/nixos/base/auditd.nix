{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  cfg = config.modules.security.audit;
  inherit (config.services) openssh;

  # Audit trail for login sessions, so that a stolen deployment key leaves a
  # record of what each session did; see SECURITY.md ("Audit trail").
  # `auditctl -R` aborts at the first watch whose path is missing, leaving
  # auditing off, so every watched path must exist when the rules load.

  # Secrets are symlinks into a per-deploy generation under the agenix ramfs,
  # which a per-file watch would lose on the next deploy; watch the ramfs tree.
  agenixSecrets = lib.optionals (options ? age) (lib.attrValues config.age.secrets);
  hasAgenix = agenixSecrets != [ ];
  credentialDirs = lib.optional hasAgenix config.age.secretsMountPoint;
  credentialFiles = lib.unique (
    map (secret: secret.path) (lib.filter (secret: !secret.symlink) agenixSecrets)
    # The host key is also agenix's identity: reading it decrypts every secret.
    ++ lib.optionals openssh.enable (map (key: key.path) openssh.hostKeys)
    ++ lib.optionals hasAgenix config.age.identityPaths
  );

  identityFiles = map (name: "/etc/${name}") [
    "passwd"
    "shadow"
    "group"
    "gshadow"
    "sudoers"
  ];

  watchedDirs = credentialDirs ++ [
    "/etc/ssh"
    "/etc/pam.d"
    "/etc/nix"
    "/etc/audit"
    "/var/log/audit"
  ];
  watchedFiles = credentialFiles ++ identityFiles ++ [ "/nix/var/nix/profiles/system" ];

  watchFile =
    key: perm: path:
    "-a always,exit -F path=${path} -F perm=${perm} -k ${key}";
  watchDir =
    key: perm: dir:
    "-a always,exit -F dir=${dir} -F perm=${perm} -k ${key}";
  # A b64-only syscall rule misses 32-bit binaries.
  arches = [ "b64" ] ++ lib.optional pkgs.stdenv.hostPlatform.isx86_64 "b32";
  perArch = rule: map (arch: "-a always,exit -F arch=${arch} ${rule}") arches;
in
{
  options.modules.security.audit.enable = lib.mkEnableOption ''
    the Linux audit trail (auditd) for login sessions: every command run as
    root, access to decrypted secrets and SSH host keys, and changes to SSH,
    account, PAM, Nix trust and audit configuration. Logs stay in
    /var/log/audit on the host
  '';

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        # auditctl -R splits fields on whitespace; it does not shell-unquote paths.
        assertion = lib.all (path: builtins.match ".*[[:space:]].*" path == null) (
          watchedDirs ++ watchedFiles
        );
        message = "modules.security.audit: audited paths cannot contain whitespace in the native auditctl rule file.";
      }
    ];

    security.auditd.enable = true;
    security.audit = {
      enable = true;
      backlogLimit = lib.mkDefault 8192;
      # The first matching exit rule sets the key: specific watches go first.
      rules = lib.mkBefore (
        # Evaluated at fork: tasks without a login uid (everything systemd
        # starts) get no audit context, so no per-syscall cost.
        [ "-a never,task -F auid=unset" ]
        ++ map (watchFile "credential-access" "rwa") credentialFiles
        ++ map (watchDir "credential-access" "rwa") credentialDirs
        ++ [ (watchDir "ssh-config" "wa" "/etc/ssh") ]
        ++ map (watchFile "identity" "wa") identityFiles
        ++ [
          (watchDir "identity" "wa" "/etc/pam.d")
          (watchDir "nix-trust" "wa" "/etc/nix")
          (watchFile "nix-trust" "wa" "/nix/var/nix/profiles/system")
          (watchDir "audit-config" "wa" "/etc/audit")
          (watchDir "audit-config" "wa" "/var/log/audit")
        ]
        ++ perArch "-S init_module,finit_module,delete_module -k kernel-module"
        ++ perArch "-S execve,execveat -F euid=0 -F auid!=unset -k root-session"
        ++ [
          "-a always,exit -S all -F exit=-EACCES -F auid!=unset -k access-denied"
          "-a always,exit -S all -F exit=-EPERM -F auid!=unset -k access-denied"
        ]
      );
    };

    security.auditd.settings = {
      log_file = "/var/log/audit/audit.log";
      max_log_file_action = "rotate";
      max_log_file = 50; # MiB
      num_logs = 5;
    };

    # Parents of watches that may not exist yet on a fresh system.
    systemd.tmpfiles.rules = [
      "d /var/log/audit 0700 root root -"
      "d /nix/var/nix/profiles 0755 root root -"
    ];

    # A watch binds to the inode present at load time, so load after the
    # bind mounts (preservation), tmpfiles and the agenix ramfs.
    systemd.services.audit-rules-nixos = {
      after = [
        "local-fs.target"
        "systemd-tmpfiles-setup.service"
      ]
      ++ lib.optional hasAgenix "agenix-install-secrets.service";
      unitConfig.RequiresMountsFor = lib.unique (watchedDirs ++ map dirOf watchedFiles);
    };
  };
}
