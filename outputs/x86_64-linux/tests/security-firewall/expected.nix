{
  lib,
  outputs,
}:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (
  name: name == "ai-niri" || name == "shoukei-niri"
)
