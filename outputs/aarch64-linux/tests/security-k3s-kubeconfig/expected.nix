{
  lib,
  outputs,
}:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (name: {
  # Only the control-plane (master) nodes write the admin kubeconfig; agents
  # (workers) connect to the master and have no --write-kubeconfig-* flags.
  mode600 = lib.hasInfix "-master-" name;
  mode644 = false;
})
