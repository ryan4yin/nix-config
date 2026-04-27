{ pkgs, ... }:
{
  programs = {
    neovim = {
      enable = true;

      viAlias = true;
      vimAlias = true;

      withRuby = false;
      withPython3 = false;
    };
  };
}
