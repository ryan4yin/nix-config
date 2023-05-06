{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./browsers.nix
    ./common.nix
    ./git.nix
    ./media.nix
    ./nixos-cn.nix
    ./vscode.nix
    ./xdg.nix
  ];
}