{
  lib,
  inputs,
}:
# Colmena must deploy the system that nixosConfigurations evaluates and builds.
lib.genAttrs [ "akane" ] (name: inputs.self.colmenaHive.toplevel.${name}.drvPath)
