{
  inputs,
  lib,
  system,
  genSpecialArgs,
  nixos-modules,
  home-modules ? [ ],
  myvars,
  hostName,
  ...
}:
let
  pkgs = import inputs.nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
in
pkgs.testers.runNixOSTest {
  name = "NixOS Tests for Idols ${hostName}";

  node = {
    inherit pkgs;
    specialArgs = genSpecialArgs system;
    pkgsReadOnly = false;
  };

  nodes = {
    ${hostName}.imports = nixos-modules;
  };

  # The node is available both as a Python object and as a hostname in the
  # virtual network.
  testScript = ''
    ${hostName}.wait_for_unit("network-online.target")

    ${hostName}.succeed("curl https://baidu.com")
  '';
}
