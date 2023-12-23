args:
with args;
with allSystemAttrs; let
  macosSystem = import ../lib/macosSystem.nix;
  base_args = {
    inherit nix-darwin home-manager;
    nixpkgs = nixpkgs-darwin;
  };
in {
  # macOS's configuration
  darwinConfigurations = {
    harmonica = macosSystem (
      libAttrs.mergeAttrsList [
        base_args
        darwin_harmonica_modules
        {
          system = allSystemAttrs.x64_darwin;
          specialArgs = allSystemSpecialArgs.x64_darwin;
        }
      ]
    );

    fern = macosSystem (
      libAttrs.mergeAttrsList [
        base_args
        darwin_fern_modules
        {
          system = aarch64_darwin;
          specialArgs = allSystemSpecialArgs.aarch64_darwin;
        }
      ]
    );
  };
}
