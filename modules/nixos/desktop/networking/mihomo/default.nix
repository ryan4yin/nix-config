{
  config,
  lib,
  myvars,
  pkgs,
  ...
}:
# Native mihomo core + metacubexd dashboard, replacing the Clash Verge GUI: the
# GUI crashed (SIGFPE) and reopened a fake-IP leak window on every core restart.
#
# The config stays OUT of the Nix store (it holds subscription URLs and the
# controller secret) and reaches the service through systemd's LoadCredential.
# This module only wires up the service; generate the file with ./generate.nu.
# See README.md for usage and the routing notes, in particular why the config
# must keep `ipv6: false`: mihomo does not proxy TCP to an IPv6 fake-IP
# (fdfe:dcba:9876::/64), so ssh/git connections hang until they time out
# (home/base/tui/ssh.nix keeps `AddressFamily inet` as a per-client fallback).
let
  cfg = config.modules.networking.mihomo;
  configFile = "${config.users.users.${myvars.username}.home}/.config/mihomo/config.yaml";
in
{
  options.modules.networking.mihomo.enable =
    lib.mkEnableOption "the native Mihomo core with TUN and a local web UI";

  config = lib.mkIf cfg.enable {
    services.mihomo = {
      enable = true;
      package = pkgs.mihomo;
      inherit configFile;
      webui = pkgs.metacubexd;
      tunMode = true;
    };

    # The config deliberately stays out of the store, under the user's home. On
    # tmpfs-root hosts that path is a persistent bind mount, so make the service
    # wait for it: otherwise activation can start mihomo before the mount is up
    # and fail with "Failed to set up credentials: No such file or directory".
    systemd.services.mihomo.unitConfig.RequiresMountsFor = builtins.dirOf configFile;
  };
}
