{
  self,
  inputs,
  constants,
}: let
  inherit (inputs.nixpkgs) lib;
  mylib = import ../lib {inherit lib;};
  vars = import ./vars.nix;
  vars_networking = import ./vars_networking.nix {inherit lib;};

  specialArgsForSystem = system:
    {
      inherit (constants) username userfullname useremail;
      inherit mylib vars_networking;
      # use unstable branch for some packages to get the latest updates
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system; # refer the `system` parameter form outer scope recursively
        # To use chrome, we need to allow the installation of non-free software
        config.allowUnfree = true;
      };
      pkgs-stable = import inputs.nixpkgs-stable {
        inherit system;
        # To use chrome, we need to allow the installation of non-free software
        config.allowUnfree = true;
      };

      # my private secrets, it's a private repository, you need to replace it with your own.
      # use ssh protocol to authenticate via ssh-agent/ssh-key, and shallow clone to save time
      mysecrets = ../secrets/secrets-data;
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
