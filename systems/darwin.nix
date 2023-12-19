args:
with args; let
  macosSystem = import ../lib/macosSystem.nix;
  system = x64_darwin;
  base_args = {
    inherit nix-darwin home-manager system;
    specialArgs = x64_darwin_specialArgs;
    nixpkgs = nixpkgs-darwin;
  };
in {
  # macOS's configuration, for work.
  darwinConfigurations = {
    harmonica =
      macosSystem (base_args
        // darwin_harmonica_modules);
  };
}
