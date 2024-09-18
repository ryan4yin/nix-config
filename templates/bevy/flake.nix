# https://github.com/bevyengine/bevy/blob/v0.14.2/docs/linux_dependencies.md#nix
{
  description = "Bevy Game Engine - Rust Lang";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    rust-overlay,
    ...
  }: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    # Helper function to generate a set of attributes for each system
    forAllSystems = func: (nixpkgs.lib.genAttrs systems func);
  in {
    devShells = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [(import rust-overlay)];
      };
      lib = pkgs.lib;
    in {
      default = pkgs.mkShell rec {
        nativeBuildInputs = with pkgs; [
          pkg-config
        ];
        buildInputs = with pkgs; [
          udev
          alsa-lib
          vulkan-loader
          xorg.libX11
          xorg.libXcursor
          xorg.libXi
          xorg.libXrandr # To use the x11 feature
          libxkbcommon
          wayland # To use the wayland feature

          # rust toolchain
          rust-analyzer
        ];
        LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
      };
    });
  };
}
