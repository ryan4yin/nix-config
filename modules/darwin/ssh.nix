{myvars, ...}: {
  services.openssh.enable = false;

  programs.ssh = myvars.networking.ssh;
}
