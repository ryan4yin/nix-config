{ outputs, ... }:
let
  inherit (outputs) nixosConfigurations;
in
builtins.mapAttrs (name: {
  enabled = nixosConfigurations.${name}.config.networking.firewall.enable;
}) nixosConfigurations
