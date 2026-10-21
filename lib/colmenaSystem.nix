# colmena - Remote Deployment via SSH
#
# Only the deployment settings live here. `outputs/default.nix` takes each node's modules,
# specialArgs and nixpkgs from the host's `nixosConfigurations` entry, so colmena deploys the
# system that `just eval-host`, `just build-host` and `just test` evaluate.
{
  tags,
  ssh-user,
  # optional override; defaults to the host name. Use an IP when the host's
  # DNS name is not resolvable yet (e.g. right after a hostname change).
  targetHost ? null,
  ...
}:
{ name, ... }:
{
  deployment = {
    inherit tags;
    targetUser = ssh-user;
    targetHost = if targetHost != null then targetHost else name;
  };
}
