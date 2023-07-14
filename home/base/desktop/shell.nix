
{ ... }: {
  programs.bash = {
    # load the alias file for work
    bashrcExtra = ''
      source /run/agenix/alias-for-work.bash
    '';
  };

  programs.nushell = {
    # load the alias file for work
    extraConfig = ''
      source /run/agenix/alias-for-work.nushell
    '';
  };

}
