{
  programs.starship = {
    enable = true;

    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;

    # https://starship.rs/config/
    settings = {
      # Get editor completions based on the config schema
      "$schema" = "https://starship.rs/config-schema.json";
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      aws = {
        symbol = "☁️ 🅰 ";
      };
      gcloud = {
        # do not show the account/project's info
        # to avoid the leak of sensitive information when sharing the terminal
        format = "on [$symbol$active(\($region\))]($style) ";
        symbol = "☁️ 🅶 ️";
      };
      kubernetes = {
        symbol = "⛵";
        disabled = false;
      };
      os.disabled = false;
    };
  };
}
