{config, ...}: {
  programs.starship = {
    enable = true;
    
    enableBashIntegration = true;
    enableNushellIntegration = true;
    
    settings = {
      character = {
        success_symbol = "[›](bold green)";
        error_symbol = "[›](bold red)";
      };
    };
  };
}