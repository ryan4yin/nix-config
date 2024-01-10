{
  # https://github.com/LnL7/nix-darwin/blob/master/modules/programs/gnupg.nix
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = false;
  };
}
