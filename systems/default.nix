{
  self,
  inputs,
  constants,
}: let
  lib = inputs.nixpkgs.lib;
  vars = import ./vars.nix;

  specialArgsForSystem = system:
    {
      inherit (constants) username userfullname useremail;
      # use unstable branch for some packages to get the latest updates
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system; # refer the `system` parameter form outer scope recursively
        # To use chrome, we need to allow the installation of non-free software
        config.allowUnfree = true;
      };
    }
    // inputs;

  allSystemSpecialArgs = builtins.listToAttrs (
    map
    (attr: {
      name = attr + "_specialArgs";
      value = specialArgsForSystem constants.${attr};
    })
    [
      "x64_system"
      "aarch64_system"
      "riscv64_system"
      "x64_darwin"
      "aarch64_darwin"
    ]
  );

  args = lib.attrsets.mergeAttrsList [
    inputs
    constants
    vars
    allSystemSpecialArgs
    {inherit self;}
  ];
in
  lib.attrsets.mergeAttrsList [
    (import ./nixos.nix args)
    (import ./darwin.nix args)
    (import ./colmena.nix args)
  ]
