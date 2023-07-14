{ ... }:
{
  imports = [
    ../server
    ./neovim
    
    ./development.nix
    ./media.nix
    ./shell.nix
  ];

}
