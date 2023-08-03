{...}: {
  imports = [
    ../server

    ./cloud
    ./container
    ./neovim
    ./terminal

    ./development.nix
    ./helix.nix
    ./media.nix
    ./shell.nix
  ];
}
