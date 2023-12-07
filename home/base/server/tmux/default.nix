{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    shell = "${pkgs.nushell}/bin/nu";

    # Resize the window to the size of the smallest session for which it is the current window.
    #
    aggressiveResize = true;

    # https://github.com/tmux-plugins/tmux-sensible
    # tmux-sensible overwrites default tmux shortcuts, makes them more sane.
    sensibleOnTop = true;

    # https://github.com/sxyazi/yazi/wiki/Image-preview-within-tmux
    extraConfig = ''
      set -g allow-passthrough on

      set -ga update-environment TERM
      set -ga update-environment TERM_PROGRAM
    '';
    # keyMode = "vi";  # default is emacs

    baseIndex = 1; # start index from 1
    escapeTime = 0; # do not wait for escape key

    plugins = with pkgs.tmuxPlugins; [
      {
        # theme
        # https://github.com/catppuccin/tmux
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha' # or frappe, macchiato, mocha
          set -g @catppuccin_window_status_enable "yes"
        '';
      }

      # https://github.com/tmux-plugins/tmux-yank
      # Enables copying to system clipboard.
      yank

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
