{username, ...}: {
  imports = [
    ../base/desktop
    ../base/core.nix

    ./proxychains
    ./core.nix
    ./rime-squirrel.nix
    ./shell.nix
  ];
}
