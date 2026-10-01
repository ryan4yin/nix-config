{ pkgs, ... }:
#############################################################
#
#  Fern - MacBook Pro 2024 14-inch M4 Pro 48G, mainly for business.
#
#############################################################
let
  hostname = "frieren";
in
{
  networking.hostName = hostname;
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;

  # CanoKey hardware security key: PC/SC tooling (`pcsc_scan`) for troubleshooting.
  # The key itself uses the macOS built-in PC/SC + HID stacks; the FIDO2/WebAuthn
  # udev rules used on Linux do not apply here.
  environment.systemPackages = with pkgs; [
    pcsclite
    pcsc-tools
  ];
}
