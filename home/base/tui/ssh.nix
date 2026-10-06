{
  config,
  lib,
  mysecrets,
  ...
}:
{
  home.file.".ssh/romantic.pub".source = "${mysecrets}/public/romantic.pub";

  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;
    settings."*" = {
      ForwardAgent = false;
      AddKeysToAgent = "yes";
      Compression = true;
      ServerAliveInterval = 0;
      ServerAliveCountMax = 3;
      HashKnownHosts = false;
      UserKnownHostsFile = "~/.ssh/known_hosts";
      ControlMaster = "no";
      ControlPath = "~/.ssh/master-%r@%n:%p";
      ControlPersist = "no";
    };

    settings = {
      "github.com" = {
        # avoid mihomo fake-IP6 hang, see modules/nixos/desktop/networking/mihomo/
        AddressFamily = "inet";
        HostName = "ssh.github.com";
        Port = 443;
        User = "git";
        IdentitiesOnly = true;
      };

      "192.168.*" = {
        ForwardAgent = true;
        # decrypted secret: AI agents must not read it
        IdentityFile = "/etc/agenix/ssh-key-romantic";
        IdentitiesOnly = true;
      };
    };
  };

  # Keep ~/.ssh/config a real, user-owned file rather than a /nix/store symlink.
  #
  # OpenSSH accepts a config owned by root or the invoking user, but
  # bubblewrap-based sandboxes (`--unshare-user`) expose root-owned store files
  # as `nobody`, which trips the check (`Bad owner or permissions`).  Disabling
  # the home.file entry keeps Home Manager's linker out of the way; `install`
  # writes a fresh 0600 copy on each activation.
  home.file.".ssh/config".enable = false;
  home.activation.sshConfigRegularFile = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    run install -D -m 600 ${config.home.file.".ssh/config".source} "$HOME/.ssh/config"
  '';
}
