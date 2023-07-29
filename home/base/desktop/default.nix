{...}: {
  imports = [
    ../server

    ./neovim

    ./alacritty.nix
    ./development.nix
    ./helix.nix
    ./kitty.nix
    ./media.nix
    ./shell.nix
  ];
}
