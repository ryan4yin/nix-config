{
  inputs,
  lib,
  system,
  genSpecialArgs,
  nixos-modules,
  # TODO: test home-manager too.
  home-modules ? [],
  myvars,
  ...
}: let
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
in
  pkgs.testers.runNixOSTest {
    name = "NixOS Tests for Idols Ruby";

    node = {
      inherit pkgs;
      specialArgs = genSpecialArgs system;
      pkgsReadOnly = false;
    };

    nodes = {
      ruby.imports = nixos-modules;
    };

    # Note that machine1 and machine2 are now available as
    # Python objects and also as hostnames in the virtual network
    testScript = ''
      ruby.wait_for_unit("network-online.target")

      ruby.succeed("curl https://baidu.com")
    '';
  }
