{pkgs, ...}: {
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
      use ${pkgs.nu_scripts}/custom-completions/git/git-completions.nu *
      use ${pkgs.nu_scripts}/custom-completions/glow/glow-completions.nu *
      use ${pkgs.nu_scripts}/custom-completions/make/make-completions.nu *
      use ${pkgs.nu_scripts}/custom-completions/nix/nix-completions.nu *
      use ${pkgs.nu_scripts}/custom-completions/man/man-completions.nu *
      use ${pkgs.nu_scripts}/custom-completions/cargo/cargo-completions.nu *
      use ${pkgs.nu_scripts}/custom-completions/zellij/zellij-completions.nu *
    '';
  };
}
