{myvars, ...}: {
  programs.ssh.extraConfig = myvars.networking.ssh.extraConfig;
}
