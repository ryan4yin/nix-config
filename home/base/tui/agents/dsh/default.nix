{
  config,
  ...
}:
let
  # Out-of-store so repo edits apply without a rebuild (see README.md).
  sharedPatch = "${config.home.homeDirectory}/nix-config/home/base/tui/agents/dsh/cordis.patch.yml";
in
{
  # The shared dsh policy, read as $DSH_HOME/cordis.patch.yml.
  home.file.".dsh/cordis.patch.yml".source = config.lib.file.mkOutOfStoreSymlink sharedPatch;
}
