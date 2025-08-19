{
  myvars,
  lib,
  outputs,
}:
let
  username = myvars.username;
  hosts = [
    "ai-hyprland"
    "ai-niri"
    "ruby"
    "k3s-prod-1-master-1"
  ];
in
lib.genAttrs hosts (
  name: outputs.nixosConfigurations.${name}.config.home-manager.users.${username}.home.homeDirectory
)
