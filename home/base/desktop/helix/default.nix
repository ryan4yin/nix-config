{ pkgs, lib, ... }:

{
  xdg.configFile."helix/themes/catppuccin_mocha.toml".source = ./theme_catppuccin_mocha.toml;

  programs.helix = {
    enable = true;
    package = pkgs.helix;
    settings = {
      theme = "catppuccin_mocha";
      editor = {
        line-number = "relative";
        lsp.display-messages = true;
      };
      keys.normal = {
        space.space = "file_picker";
        space.w = ":w";
        space.q = ":q";
        esc = [ "collapse_selection" "keep_primary_selection" ];
      };
    };
  };
}
