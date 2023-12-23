{
  self,
  inputs,
  constants,
}: let
  inherit (inputs.nixpkgs) lib;
  mylib = import ../lib {inherit lib;};
  vars = import ./vars.nix;

  specialArgsForSystem = system:
    {
      inherit (constants) username userfullname useremail;
      inherit mylib;
      # use unstable branch for some packages to get the latest updates
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system; # refer the `system` parameter form outer scope recursively
        # To use chrome, we need to allow the installation of non-free software
        config.allowUnfree = true;
      };
    }
    // inputs;

  allSystemSpecialArgs =
    mylib.attrs.mapAttrs
    (_: specialArgsForSystem)
    constants.allSystemAttrs;

  args = mylib.attrs.mergeAttrsList [
    inputs
    constants
    vars
    {inherit self lib mylib allSystemSpecialArgs;}
  ];
in
  mylib.attrs.mergeAttrsList [
    (import ./nixos.nix args)
    (import ./darwin.nix args)
    (import ./colmena.nix args)
  ]
