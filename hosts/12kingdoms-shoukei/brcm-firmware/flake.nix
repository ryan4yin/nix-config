{
  # a flake for testing
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    packages."${system}".default = pkgs.callPackage ./default.nix {};
  };
}
