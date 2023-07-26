{pkgs, ...}: let
  buildTmuxPlugin = pkgs.tmuxPlugins.mkTmuxPlugin;
in {
  draculaTheme = buildTmuxPlugin {
    pluginName = "dracula";
    version = "v2.2.0";
    src = builtins.fetchTarball {
      name = "dracula-tmux-v2.2.0";
      url = "https://github.com/dracula/tmux/archive/refs/tags/v2.2.0.tar.gz";
      sha256 = "sha256:0v2k994yy4xx2iw8qxg7qphw46gq2qmg496i3a3h9b6jgwxqm7zn";
    };
  };
}
