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

  # mapAttrs'
  # (name: value: nameValuePair ("foo_" + name) ("bar-" + value))
  # { x = "a"; y = "b"; }
  #   => { foo_x = "bar-a"; foo_y = "bar-b"; }
  allSystemSpecialArgs = with lib.attrsets;
    mapAttrs'
    (name: value: nameValuePair (name + "_specialArgs") (specialArgsForSystem value))
    constants.systemAttrs;

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
