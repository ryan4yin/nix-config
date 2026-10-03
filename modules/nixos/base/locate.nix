{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.locate;
in
{
  options.modules.locate.enable = lib.mkEnableOption ''
    Whole-filesystem filename search (`locate`), backed by plocate. It
    complements `nix-index`/`nix-locate`, which only index the nix store.

    The database lives at /var/cache/locatedb. Hosts with an ephemeral root
    must persist /var/cache as a directory (see hosts/idols-ai/preservation.nix):
    plocate replaces the DB via a temp file + rename, which fails on a
    bind-mounted file.

    Off by default: the daily `updatedb` scan is only worth it on hosts that
    persist /var/cache and actually use `locate` (currently idols-ai).
  '';

  config = lib.mkIf cfg.enable {
    services.locate = {
      enable = true;
      package = pkgs.plocate;
    };
  };
}
