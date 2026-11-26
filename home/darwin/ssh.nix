{
  # Apple's ssh-agent refuses the FIDO keys that AddKeysToAgent hands it
  # (home/base/tui/ssh.nix); run OpenSSH's own agent instead.
  services.ssh-agent.enable = true;
}
