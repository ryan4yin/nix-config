{...}: {
  imports = [
    ../server

    ./alacritty
    ./helix
    ./neovim

    ./development.nix
    ./kitty.nix
    ./media.nix
    ./shell.nix
  ];
}
