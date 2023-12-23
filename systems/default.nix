{
  self,
  inputs,
  constants,
}: let
  inherit (inputs.nixpkgs) lib;
  libAttrs = import ../lib/attrs.nix {inherit lib;};
  vars = import ./vars.nix;

  specialArgsForSystem = system:
    {
      inherit (constants) username userfullname useremail;
      inherit libAttrs;
      # use unstable branch for some packages to get the latest updates
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system; # refer the `system` parameter form outer scope recursively
        # To use chrome, we need to allow the installation of non-free software
        config.allowUnfree = true;
      };
    }
    // inputs;

  allSystemSpecialArgs =
    libAttrs.mapAttrs
    (_: specialArgsForSystem)
    constants.allSystemAttrs;

  args = libAttrs.mergeAttrsList [
    inputs
    constants
    vars
    {inherit self lib libAttrs allSystemSpecialArgs;}
  ];
in
  libAttrs.mergeAttrsList [
    (import ./nixos.nix args)
    (import ./darwin.nix args)
    (import ./colmena.nix args)
  ]
