{
  lib,
  outputs,
  ...
}:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (
  name:
  let
    userGroups = outputs.nixosConfigurations.${name}.config.users.users.ryan.extraGroups;
  in
  {
    # Groups that grant root-equivalent or otherwise over-broad access. The
    # normal user must never be a member of any of them:
    #   docker / podman -> the rootful container socket (~ root)
    #   disk            -> raw block devices (~ root)
    #   kvm             -> /dev/kvm
    #   input           -> read/forge input events (keylogging)
    userHasDockerAccess = builtins.elem "docker" userGroups;
    userHasPodmanAccess = builtins.elem "podman" userGroups;
    userHasDiskAccess = builtins.elem "disk" userGroups;
    userHasKvmAccess = builtins.elem "kvm" userGroups;
    userHasInputAccess = builtins.elem "input" userGroups;
  }
)
