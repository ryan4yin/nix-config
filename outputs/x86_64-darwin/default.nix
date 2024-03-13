{
  lib,
  inputs,
  ...
} @ args: let
  inherit (inputs) haumea;

  # Contains all the flake outputs of this system architecture.
  data = haumea.lib.load {
    src = ./src;
    # pass all inputs into every haumea module,
    # as if the file being loaded is wrapped with `with inputs;`
    loader = haumea.lib.loaders.scoped;
    inputs = args;
  };
  # nix file names is redundant, so we remove it.
  dataWithoutPaths = builtins.attrValues data;

  # Merge all the machine's data into a single attribute set.
  outputs = {
    darwinConfigurations = lib.attrsets.mergeAttrsList (map (it: it.darwinConfigurations or {}) dataWithoutPaths);
  };
in
  outputs
