# https://github.com/bevyengine/bevy/blob/v0.14.2/docs/linux_dependencies.md#nix
{
  description = "Bevy Game Engine - Rust Lang";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    fenix,
    ...
  }: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    # Helper function to generate a set of attributes for each system
    forAllSystems = func: (nixpkgs.lib.genAttrs systems func);
  in {
    devShells = forAllSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [fenix.overlays.default];
      };
      lib = pkgs.lib;
    in {
      default = pkgs.mkShell rec {
        nativeBuildInputs = with pkgs; [
          pkg-config
          clang
          # lld is much faster at linking than the default Rust linker
          lld
        ];
        buildInputs = with pkgs;
          [
            # rust toolchain
            (pkgs.fenix.complete.withComponents [
              "cargo"
              "clippy"
              "rust-src"
              "rustc"
              "rustfmt"
            ])
            # use rust-analyzer-nightly for better type inference
            rust-analyzer-nightly
            cargo-watch
          ]
          # https://github.com/bevyengine/bevy/blob/v0.14.2/docs/linux_dependencies.md#nix
          ++ (lib.optionals pkgs.stdenv.isLinux [
            udev
            alsa-lib
            vulkan-loader
            xorg.libX11
            xorg.libXcursor
            xorg.libXi
            xorg.libXrandr # To use the x11 feature
            libxkbcommon
            wayland # To use the wayland feature
          ])
          ++ (pkgs.lib.optionals pkgs.stdenv.isDarwin [
            # https://discourse.nixos.org/t/the-darwin-sdks-have-been-updated/55295/1
            apple-sdk_15
          ]);
        LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
      };
    });
  };
}
