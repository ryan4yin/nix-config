{vars_networking, ...}: {
  programs.ssh.extraConfig = vars_networking.ssh.extraConfig;
}
