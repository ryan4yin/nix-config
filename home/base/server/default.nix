{...}: {
  imports = [
    ./nushell
    ./tmux
    ./zellij

    ./bash.nix
    ./bat.nix
    ./core.nix
    ./git.nix
    ./starship.nix
  ];
}
