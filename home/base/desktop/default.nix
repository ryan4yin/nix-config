{ ... }:
{
  imports = [
    ./alacritty
    ../server
    ./neovim
    
    ./development.nix
    ./kitty.nix
    ./media.nix
    ./shell.nix
  ];

}
