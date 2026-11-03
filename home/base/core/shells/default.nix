{ config, ... }:
{
  # Bash remains the login shell.
  programs.bash.enable = true;

  programs.nushell = {
    enable = true;
    loadSessionVariables = true;
    configFile.source = ./config.nu;
  };

  # Tools installed outside Nix.
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/go/bin"
    "${config.home.homeDirectory}/.cargo/bin"
    "${config.home.homeDirectory}/.npm/bin"
  ];
}
