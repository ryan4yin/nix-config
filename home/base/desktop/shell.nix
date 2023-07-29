{ nushell-scripts, ...}: {
  programs.bash = {
    # load the alias file for work
    bashrcExtra = ''
      alias_for_work=/etc/agenix/alias-for-work.bash
      if [ -f $alias_for_work ]; then
        . $alias_for_work
      else
        echo "No alias file found for work"
      fi
    '';
  };

  programs.nushell = {
    # load the alias file for work
    # the file must exist, otherwise nushell will complain about it!
    #
    # currently, nushell does not support conditional sourcing of files
    # https://github.com/nushell/nushell/issues/8214
    extraConfig = ''
      source /etc/agenix/alias-for-work.nushell
      use ${nushell-scripts}/custom-completions/git/git-completions.nu *
      use ${nushell-scripts}/custom-completions/glow/glow-completions.nu *
      use ${nushell-scripts}/custom-completions/make/make-completions.nu *
      use ${nushell-scripts}/custom-completions/nix/nix-completions.nu *
      use ${nushell-scripts}/custom-completions/man/man-completions.nu *
      use ${nushell-scripts}/custom-completions/cargo/cargo-completions.nu *
      use ${nushell-scripts}/custom-completions/zellij/zellij-completions.nu *
    '';
  };
}
