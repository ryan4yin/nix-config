{
  config,
  pkgs,
  lib,
  myvars,
  mylib,
  ...
}:
let
  hostName = "k3s-test-1-worker-1"; # Define your hostname.

  coreModule = mylib.genMicrovmGuestModule {
    inherit pkgs hostName;
    inherit (myvars) networking;
    vcpu = 4;
    mem = 16384;
    varSize = 20480;
  };
  k3sModule = mylib.genK3sAgentModule {
    inherit pkgs;
    tokenFile = config.age.secrets."k3s-test-1-token".path;
    # use my own domain & kube-vip's virtual IP for the API server
    # so that the API server can always be accessed even if some nodes are down
    masterHost = "test-cluster-1.writefor.fun";
    # Placement is enforced by the masters' control-plane taint. No node label:
    # kubelet refuses to self-assign the reserved node-role.kubernetes.io/* labels.
  };
in
{
  imports =
    (mylib.scanPaths ./.)
    ++ (map mylib.relativeToRoot [
      "secrets/nixos.nix"
      "modules/nixos/server/server.nix"
    ])
    ++ [
      coreModule
      k3sModule
    ];

  # k3s-test-1-token lives in this secret group
  modules.secrets.server.kubernetes.enable = true;

  # The guest reuses the host's already-instantiated nixpkgs (shared store),
  # so nixpkgs.config may not be set. The shared base modules set
  # nixpkgs.config.allowUnfree, so force it empty here.
  nixpkgs.config = lib.mkForce { };
}
