{
  config,
  mysecrets,
  ...
}:
{
  home.file.".ssh/romantic.pub".source = "${mysecrets}/public/romantic.pub";

  programs.ssh = {
    enable = true;

    # default config
    enableDefaultConfig = false;
    matchBlocks."*" = {
      forwardAgent = false;
      # "a private key that is used during authentication will be added to ssh-agent if it is running"
      addKeysToAgent = "yes";
      compression = true;
      serverAliveInterval = 0;
      serverAliveCountMax = 3;
      hashKnownHosts = false;
      userKnownHostsFile = "~/.ssh/known_hosts";
      controlMaster = "no";
      controlPath = "~/.ssh/master-%r@%n:%p";
      controlPersist = "no";
    };

    matchBlocks = {
      "github.com" = {
        # "Using SSH over the HTTPS port for GitHub"
        # "(port 22 is banned by some proxies / firewalls)"
        hostname = "ssh.github.com";
        port = 443;
        user = "git";

        # Specifies that ssh should only use the identity file explicitly configured above
        # required to prevent sending default identity files first.
        identitiesOnly = true;
      };

      "192.168.*" = {
        # "allow to securely use local SSH agent to authenticate on the remote machine."
        # "It has the same effect as adding cli option `ssh -A user@host`"
        forwardAgent = true;
        # "romantic holds my homelab~"
        identityFile = "/etc/agenix/ssh-key-romantic";
        identitiesOnly = true;
      };
    };
  };
}
