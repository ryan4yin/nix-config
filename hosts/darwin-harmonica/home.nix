_: {
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host github.com
        Hostname github.com
        # github is controlled by harmonica~
        IdentityFile ~/.ssh/harmonica
        # Specifies that ssh should only use the identity file explicitly configured above
        # required to prevent sending default identity files first.
        IdentitiesOnly yes
    '';
  };
  modules.editors.emacs = {
    enable = true;
  };
}
