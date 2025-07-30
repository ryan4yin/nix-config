_:
#############################################################
#
#  Fern - MacBook Pro 2022 13-inch M2 16G.
#
#############################################################
let
  hostname = "fern";
in
{
  networking.hostName = hostname;
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;
}
