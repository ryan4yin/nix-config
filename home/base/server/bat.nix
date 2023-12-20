{
  pkgs,
  nur-ryan4yin,
  ...
}: {
  # a cat(1) clone with syntax highlighting and Git integration.
  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      theme = "catppuccin-mocha";
    };
    themes = {
      # https://raw.githubusercontent.com/catppuccin/bat/main/Catppuccin-mocha.tmTheme
      catppuccin-mocha = {
        src = nur-ryan4yin.packages.${pkgs.system}.catppuccin-bat;
        file = "Catppuccin-mocha.tmTheme";
      };
    };
  };
}
