_:
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
}
