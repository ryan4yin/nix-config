args:
with args; let
  macosSystem = import ../lib/macosSystem.nix;
  x64_args = {
    inherit nix-darwin home-manager;
    system = allSystemAttrs.x64_darwin;
    specialArgs = allSystemSpecialArgs.x64_darwin;
    nixpkgs = nixpkgs-darwin;
  };
  aarch64_args = {
    inherit nix-darwin home-manager;
    system = aarch64_darwin;
    specialArgs = aarch64_darwin_specialArgs;
    nixpkgs = nixpkgs-darwin;
  };
in {
  # macOS's configuration
  darwinConfigurations = {
    harmonica =
      macosSystem (x64_args
        // darwin_harmonica_modules);

    fern =
      macosSystem (aarch64_args
        // darwin_fern_modules);
  };
}
