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
    };
    plugins = {
      zoom = pkgs.yaziPlugins.zoom;
      toggle-pane = pkgs.yaziPlugins.toggle-pane;
      smart-enter = pkgs.yaziPlugins.smart-enter;
      vcs-files = pkgs.yaziPlugins.vcs-files;
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
        on = [
          "g"
          "c"
        ];
        run = "plugin vcs-files";
        desc = "Show Git file changes";
      }
    ];
  };
}
