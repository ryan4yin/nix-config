{ pkgs, ... }:
{
  programs.foot = {
    # foot is designed only for Linux
    enable = pkgs.stdenv.isLinux;

    # foot can also be run in a server mode. In this mode, one process hosts multiple windows.
    # All Wayland communication, VT parsing and rendering is done in the server process.
    # New windows are opened by running footclient, which remains running until the terminal window is closed.
    #
    # Advantages to run foot in server mode including reduced memory footprint and startup time.
    # The downside is a performance penalty. If one window is very busy with, for example, producing output,
    # then other windows will suffer. Also, should the server process crash, all windows will be gone.
    server.enable = true;

    # https://man.archlinux.org/man/foot.ini.5
    settings = {
      main = {
        term = "foot"; # or "xterm-256color" for maximum compatibility
        font = "Maple Mono NF CN:size=13";
        dpi-aware = "no"; # scale via window manager instead
        resize-keep-grid = "no"; # do not resize the window on font resizing

        # Spawn a nushell in login mode via `bash`
        shell = "${pkgs.bash}/bin/bash --login -c 'nu --login --interactive'";
      };

      mouse = {
        hide-when-typing = "yes";
      };
    };
  };
}
