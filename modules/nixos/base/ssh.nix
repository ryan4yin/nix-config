{ lib, ... }:
{
  # Secure by default: firewall ON everywhere unless a host explicitly disables it
  # (servers disable it in modules/nixos/server/{server,server-aarch64}.nix).
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

  # Add terminfo database of all known terminals to the system profile.
  # https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/config/terminfo.nix
  environment.enableAllTerminfo = true;
}
