{
  config,
  ...
}:
let
  # dsh persists Settings through the profile's cordis.patch.yml with an atomic
  # write (a random-suffix sibling, then a rename), and that rename replaces a
  # symlinked target instead of writing through to its referent. A file-level
  # link, store or out-of-store, therefore survives only until the first save.
  # Linking the whole profile directory keeps the write inside the checkout and
  # leaves the directory symlink intact. Same reasoning as
  # `home/base/tui/tuios`, one level up; the checkout path is hardcoded like the
  # repo's other out-of-store links.
  profileDir = "${config.home.homeDirectory}/nix-config/home/base/tui/agents/dsh/web";
in
{
  # The `web` profile's configuration, owned by hand and by the Settings UI.
  # Generated members of the profile (cordis.yml, node_modules, lock files) are
  # gitignored inside that directory rather than tracked.
  home.file.".dsh/profiles/web".source = config.lib.file.mkOutOfStoreSymlink profileDir;
}
