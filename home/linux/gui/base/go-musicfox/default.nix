{ ... }:
{
  # go-musicfox rewrites config.toml at runtime (in-app theme switch, `musicfox
  # upgrade-config`) with a temp file plus rename, which would replace a plain
  # symlink with a regular file. Same approach as fcitx5's `profile`: force the
  # declarative copy back on every activation. Runtime edits persist until the
  # next rebuild and are then reset; copy them back here manually to keep them.
  xdg.configFile."go-musicfox/config.toml" = {
    source = ./config.toml;
    force = true;
  };
}
