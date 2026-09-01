{ outputs, ... }:
let
  userGroups = outputs.nixosConfigurations.ai-niri.config.users.users.ryan.extraGroups;
in
{
  userHasDockerAccess = builtins.elem "docker" userGroups;
  userHasPodmanAccess = builtins.elem "podman" userGroups;
}
