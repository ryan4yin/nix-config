{ pkgs, ... }:
{
  # terminal file manager
  programs.yazi = {
    enable = true;
    package = pkgs.yazi;
    # Changing working directory when exiting Yazi
    enableBashIntegration = true;
    enableNushellIntegration = true;
    shellWrapperName = "yy";
    settings = {
      mgr = {
        show_hidden = true;
        sort_dir_first = true;
      };
      preview = {
        max_width = 2000;
        max_height = 2000;
      };
      plugin.prepend_fetchers = [
        {
          url = "*";
          run = "git";
          group = "git";
        }
        {
          url = "*/";
          run = "git";
          group = "git";
        }
      ];
    };
    plugins = with pkgs.yaziPlugins; {
      git = {
        package = git;
        setup = true;
        settings = {
          order = 1500;
        };
      };
      inherit
        jump-to-char
        smart-enter
        toggle-pane
        zoom
        ;
    };
    keymap.mgr.prepend_keymap = [
      {
        on = "+";
        run = "plugin zoom 1";
        desc = "Zoom in the preview";
      }
      {
        on = "=";
        run = "plugin zoom -1";
        desc = "Zoom out the preview";
      }
      {
        on = "T";
        run = "plugin toggle-pane max-preview";
        desc = "Maximize or restore the preview";
      }
      {
        on = "l";
        run = "plugin smart-enter";
        desc = "Enter the child directory, or open the file";
      }
      {
        on = "F";
        run = "plugin jump-to-char";
        desc = "Jump to the next file starting with a character";
      }
    ];
  };
}
