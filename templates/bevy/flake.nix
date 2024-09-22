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
      "x86_64-darwin"
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
          # https://discourse.nixos.org/t/develop-shell-environment-setup-for-macos/11399
          # https://github.com/NixOS/nixpkgs/blob/nixos-unstable-small/pkgs/os-specific/darwin/apple-sdk/frameworks.nix
          ++ (pkgs.lib.optionals pkgs.stdenv.isDarwin [
            # Additional darwin specific inputs can be set here
            libiconv
            darwin.apple_sdk.frameworks.Security
            darwin.apple_sdk.frameworks.ApplicationServices
            darwin.apple_sdk.frameworks.CoreVideo
            darwin.apple_sdk.frameworks.Carbon
            darwin.apple_sdk.frameworks.AppKit
          ]);
        LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
        COREAUDIO_SDK_PATH =
          pkgs.lib.optionals
          pkgs.stdenv.isDarwin
          # The coreaudio-sys crate is configured to look for things in whatever the
          # output of `xcrun --sdk macosx --show-sdk-path` is. However, this does not
          # always contain the right frameworks, and it uses system versions instead of
          # what we control via Nix. Instead of having to run a lot of extra scripts
          # to set our systems up to build, we can just create a SDK directory with
          # the same layout as the `MacOSX{version}.sdk` that XCode produces.
          (pkgs.symlinkJoin {
            name = "sdk";
            paths = with pkgs.darwin.apple_sdk.frameworks; [
              AudioToolbox
              AudioUnit
              CoreAudio
              CoreAudioTypes
              CoreFoundation
              CoreMIDI
              OpenAL
            ];
            postBuild = ''
              mkdir $out/System
              mv $out/Library $out/System
            '';
          });
      };
    });
  };
}
