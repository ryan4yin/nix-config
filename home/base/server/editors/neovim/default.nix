{pkgs, ...}: {
  programs = {
    neovim = {
      enable = true;
      package = pkgs.neovim;

      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
