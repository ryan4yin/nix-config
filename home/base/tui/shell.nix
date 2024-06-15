{pkgs-unstable, ...}: let
  inherit (pkgs-unstable) nu_scripts;
in {
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
      # completion
      use ${nu_scripts}/share/nu_scripts/custom-completions/git/git-completions.nu *
      use ${nu_scripts}/share/nu_scripts/custom-completions/glow/glow-completions.nu *
      use ${nu_scripts}/share/nu_scripts/custom-completions/just/just-completions.nu *
      use ${nu_scripts}/share/nu_scripts/custom-completions/make/make-completions.nu *
      use ${nu_scripts}/share/nu_scripts/custom-completions/man/man-completions.nu *
      use ${nu_scripts}/share/nu_scripts/custom-completions/nix/nix-completions.nu *
      use ${nu_scripts}/share/nu_scripts/custom-completions/cargo/cargo-completions.nu *
      use ${nu_scripts}/share/nu_scripts/custom-completions/zellij/zellij-completions.nu *
      # alias
      # use ${nu_scripts}/share/nu_scripts/aliases/git/git-aliases.nu *
      use ${nu_scripts}/share/nu_scripts/aliases/eza/eza-aliases.nu *
      use ${nu_scripts}/share/nu_scripts/aliases/bat/bat-aliases.nu *
    '';
  };
}
