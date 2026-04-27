{ pkgs, ... }:
{
  programs.helix = {
    enable = true;
    package = pkgs.helix;
    settings = {
      editor = {
        # Display & cursor
        line-number = "relative";
        cursorline = true;
        color-modes = true;
        scrolloff = 8;

        # Wrap long lines to the viewport (word-wrap style; does not insert hard line endings)
        soft-wrap = {
          enable = true;
        };

        # Completion / formatting
        auto-format = true;
        preview-completion-insert = true;
        completion-timeout = 5;
        idle-timeout = 200;
        end-of-line-diagnostics = "hint";

        # Save to disk on focus loss and after idle (helps LSP see disk changes)
        auto-save = {
          focus-lost = true;
          after-delay = {
            enable = true;
            timeout = 2000;
          };
        };

        # LSP: inlay hints, signature help, progress / messages in status area
        lsp = {
          display-messages = true;
          display-progress-messages = true;
          display-inlay-hints = true;
          auto-signature-help = true;
        };

        inline-diagnostics = {
          cursor-line = "hint";
          other-lines = "disable";
        };

        # Buffers tab strip, menu borders, status line layout
        bufferline = "multiple";
        popup-border = "menu";
        statusline = {
          left = [
            "mode"
            "spinner"
            "version-control"
            "file-name"
            "read-only-indicator"
            "file-modification-indicator"
          ];
          center = [ ];
          right = [
            "workspace-diagnostics"
            "diagnostics"
            "selections"
            "position"
            "position-percentage"
            "file-type"
            "file-encoding"
            "file-line-ending"
          ];
          separator = "│";
          diagnostics = [
            "error"
            "warning"
            "info"
          ];
          workspace-diagnostics = [
            "error"
            "warning"
          ];
          mode = {
            normal = "NORMAL";
            insert = "INSERT";
            select = "SELECT";
          };
        };

        # Show dotfiles in picker (project-wide ignores still apply)
        file-picker.hidden = false;

        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides.render = true;
      };

      # home/base/tui/zellij/config.kdl: Ctrl+o opens Zellij Session, so Helix never receives the
      # default Ctrl+o (jump_backward). One remap restores backward jumplist; forward stays Ctrl+i.
      # Other Zellij binds (Ctrl+s scroll, Ctrl+p pane, …): use built-in Space menu, :w / :rla, or
      # Zellij locked mode — https://zellij.dev/tutorials/colliding-keybindings/
      keys.normal."C-S-o" = "jump_backward";
    };
  };
}
