{ outputs, ... }:
let
  inherit (outputs) nixosConfigurations;
in
builtins.mapAttrs (name: {
  enabled = name == "ai-niri" || name == "shoukei-niri";
}) nixosConfigurations
