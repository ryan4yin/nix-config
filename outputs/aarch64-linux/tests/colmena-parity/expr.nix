{
  lib,
  inputs,
}:
# Colmena must deploy the system that nixosConfigurations evaluates and builds.
# Every node comes out of the same rawColmenaHive code in outputs/default.nix, so
# akane covers the x86_64 nodes too; those all read the private mysecrets input,
# which CI cannot fetch.
lib.genAttrs [ "akane" ] (name: inputs.self.colmenaHive.toplevel.${name}.drvPath)
