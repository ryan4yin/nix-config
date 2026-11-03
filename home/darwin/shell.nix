{ config, ... }:
{
  # Homebrew install locations for Apple Silicon and Intel.
  home.sessionPath = [
    "/opt/homebrew/bin"
    "/usr/local/bin"
  ];

  programs.bash.enable = true;
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
  };
}
