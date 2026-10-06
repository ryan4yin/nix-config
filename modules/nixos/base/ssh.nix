{ lib, pkgs, ... }:
{
  # Secure by default: firewall ON everywhere. Servers run the same shared
  # firewall (modules/nixos/base/networking/firewall.nix) as every other host,
  # as defence in depth behind the router.
  networking.firewall.enable = lib.mkDefault true;
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      # Secure by default: X11 forwarding off everywhere; desktops re-enable it
      # in modules/nixos/desktop/ssh.nix (needed for GUI forwarding).
      X11Forwarding = lib.mkDefault false;
      # root user is used for remote deployment, so we need to allow it
      PermitRootLogin = lib.mkDefault "prohibit-password";
      PasswordAuthentication = false; # disable password login
    };
    openFirewall = true;
  };

  # NixOS appends an `Include` of systemd's ssh_config.d drop-in to
  # /etc/ssh/ssh_config, and OpenSSH re-applies SSHCONF_CHECKPERM to included
  # files.  A bubblewrap sandbox (`--unshare-user`) exposes root-owned store
  # files as `nobody`, which would abort ssh there.  We do not use
  # systemd-ssh-proxy (.host, machine/*, unix/*, vsock/*).
  programs.ssh.systemd-ssh-proxy.enable = false;

  # Terminfo for the terminals we use, so `$TERM` resolves on hosts we SSH into.
  environment.systemPackages = [
    pkgs.ghostty.terminfo
    pkgs.kitty.terminfo
  ];
}
