{
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host github.com
        Hostname github.com
        # github is controlled by fern~
        IdentityFile ~/.ssh/fern
        # Specifies that ssh should only use the identity file explicitly configured above
        # required to prevent sending default identity files first.
        IdentitiesOnly yes
    '';
  };

  modules.editors.emacs = {
    enable = true;
  };
}
