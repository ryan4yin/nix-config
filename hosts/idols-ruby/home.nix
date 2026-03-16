{
  programs.gh.enable = true;
  programs.git.enable = true;

  programs.zellij.enable = true;
  programs.bash.enable = true;
  programs.nushell.enable = true;

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
  };
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  home.stateVersion = "25.11";
}
