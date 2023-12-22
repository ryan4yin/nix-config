_: {
  # add homebrew into PATH

  programs.bash.bashrcExtra = ''
    export PATH="/opt/homebrew/bin:$PATH"
  '';
  programs.zsh.envExtra = ''
    export PATH="/opt/homebrew/bin:$PATH"
  '';
}
