{
  config,
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
        HostName = "ssh.github.com";
        Port = 443;
        User = "git";
        IdentitiesOnly = true;
      };

      "192.168.*" = {
        ForwardAgent = true;
        IdentityFile = "/etc/agenix/ssh-key-romantic";
        IdentitiesOnly = true;
      };
    };
  };
}
