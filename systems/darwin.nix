args:
with args;
with mylib;
with allSystemAttrs; let
  base_args = {
    inherit nix-darwin home-manager;
    nixpkgs = nixpkgs-darwin;
  };
in {
  # macOS's configuration
  darwinConfigurations = {
    harmonica = macosSystem (
      attrs.mergeAttrsList [
        base_args
        darwin_harmonica_modules
        {
          system = allSystemAttrs.x64_darwin;
          specialArgs = allSystemSpecialArgs.x64_darwin;
        }
      ]
    );

    fern = macosSystem (
      attrs.mergeAttrsList [
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
