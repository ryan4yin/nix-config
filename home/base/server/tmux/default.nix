{
  config,
  pkgs,
  ...
}: let
  plugins = pkgs.tmuxPlugins // pkgs.callPackage ./custom-plugins.nix {};
in {
  programs.tmux = {
    enable = true;
    shell = "${pkgs.nushell}/bin/nu";

    # Resize the window to the size of the smallest session for which it is the current window.
    #
    aggressiveResize = true;

    # https://github.com/tmux-plugins/tmux-sensible
    # tmux-sensible overwrites default tmux shortcuts, makes them more sane.
    sensibleOnTop = true;

    # extraConfig =  builtins.readFile ./tmux.conf;
    # keyMode = "vi";  # default is emacs

    baseIndex = 1; # start index from 1
    escapeTime = 0; # do not wait for escape key
    terminal = "xterm-256color";

    plugins = with plugins; [
      draculaTheme # theme
      {
        # https://github.com/tmux-plugins/tmux-continuum
        # Continuous saving of tmux environment. Automatic restore when tmux is started.
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-save-interval '15'

          # Option to display current status of tmux continuum in tmux status line.
          set -g status-right 'Continuum status: #{continuum_status}'
        '';
      }
      {
        # https://github.com/tmux-plugins/tmux-resurrect
        # Manually persists tmux environment across system restarts.
        #   prefix + Ctrl-s - save
        #   prefix + Ctrl-r - restore
        #
        plugin = resurrect;
        # Restore Neovim sessions
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        # https://github.com/tmux-plugins/tmux-yank
        # Enables copying to system clipboard.
        plugin = yank;
      }
      # set -g @plugin 'tmux-plugins/tmux-cpu'
      {
        plugin = cpu;
        extraConfig = ''
          set -g status-right '#{cpu_bg_color} CPU: #{cpu_icon} #{cpu_percentage} | %a %h-%d %H:%M '
        '';
      }
    ];
  };
}
