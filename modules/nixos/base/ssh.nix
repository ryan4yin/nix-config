{
  lib,
  vars_networking,
  ...
}: {
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = lib.mkDefault false;

  programs.ssh = vars_networking.ssh;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = true;
      PermitRootLogin = "no"; # disable root login
      PasswordAuthentication = false; # disable password login
    };
    openFirewall = true;
  };

  # Add terminfo database of all known terminals to the system profile.
  # https://github.com/NixOS/nixpkgs/blob/nixos-23.11/nixos/modules/config/terminfo.nix
  environment.enableAllTerminfo = true;
}
