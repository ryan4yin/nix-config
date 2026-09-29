{
  pkgs,
  ...
}:
{
  # replacement of htop/nmon
  programs.btop = {
    enable = true;
    # On NixOS `modules.btop` installs the single GPU-aware build (or a
    # CAP_PERFMON wrapper), so don't let Home Manager add a second, plain btop.
    # macOS has no `modules.btop` and takes btop from Home Manager.
    package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.btop else null;
    settings = {
      # Use the terminal background so btop is transparent. No visible effect
      # inside zellij yet: its panes have been opaque since 0.44
      # (https://github.com/zellij-org/zellij/issues/5175), so this only shows
      # when btop runs directly in a translucent terminal.
      theme_background = false;
    };
  };
}
