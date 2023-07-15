
{ ... }: {
  programs.bash = {
    # load the alias file for work
    bashrcExtra = ''
      source /etc/agenix/alias-for-work.bash
    '';
  };

  programs.nushell = {
    # load the alias file for work
    extraConfig = ''
      source /etc/agenix/alias-for-work.nushell
    '';
  };

}
