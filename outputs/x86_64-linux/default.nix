{
  lib,
  inputs,
  ...
} @ args: let
  inherit (inputs) haumea;

  # Contains all the flake outputs of this system architecture.
  data = haumea.lib.load {
    src = ./src;
    inputs = args;
  };
  # nix file names is redundant, so we remove it.
  dataWithoutPaths = builtins.attrValues data;

  # Merge all the machine's data into a single attribute set.
  outputs = {
    nixosConfigurations = lib.attrsets.mergeAttrsList (map (it: it.nixosConfigurations or {}) dataWithoutPaths);
    packages = lib.attrsets.mergeAttrsList (map (it: it.packages or {}) dataWithoutPaths);
    # colmena contains some meta info, which need to be merged carefully.
    colmenaMeta = {
      nodeNixpkgs = lib.attrsets.mergeAttrsList (map (it: it.colmenaMeta.nodeNixpkgs or {}) dataWithoutPaths);
      nodeSpecialArgs = lib.attrsets.mergeAttrsList (map (it: it.colmenaMeta.nodeSpecialArgs or {}) dataWithoutPaths);
    };
    colmena = lib.attrsets.mergeAttrsList (map (it: it.colmena or {}) dataWithoutPaths);
  };

  unitTestsData = with haumea.lib;
    load {
      src = ./tests;
      inputs = args // {inherit outputs;};
      transformer = [
        (transformers.hoistAttrs "tests" "tests")
      ];
    };
in
  outputs
  // {
    inherit data unitTestsData; # for debugging purposes

    # NixOS's unit tests.
    unitTests = lib.debug.runTests unitTestsData.tests;
  }
