{ pkgs, ... }:
{
  # Whole-filesystem filename search (`locate`), backed by plocate. It complements
  # `nix-index`/`nix-locate`, which only index the nix store.
  #
  # The database lives at /var/cache/locatedb. Hosts with an ephemeral root must
  # persist /var/cache as a directory (see hosts/idols-ai/preservation.nix): plocate
  # replaces the DB via a temp file + rename, which fails on a bind-mounted file.
  services.locate = {
    enable = true;
    package = pkgs.plocate;
  };
}
