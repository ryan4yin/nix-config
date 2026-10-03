{ lib, outputs }:
let
  nodes = lib.filterAttrs (name: _: lib.hasPrefix "k3s-test-1-" name) outputs.nixosConfigurations;
in
lib.mapAttrs (
  _: host:
  let
    inherit (host.config.services) k3s;
    endpoint = "https://test-cluster-1.writefor.fun:6443";
  in
  {
    joinsViaDomain = if k3s.clusterInit then k3s.serverAddr == "" else k3s.serverAddr == endpoint;
    servingDomainSan =
      k3s.role != "server"
      || builtins.elem "--tls-san=test-cluster-1.writefor.fun" (lib.splitString " " k3s.extraFlags);
  }
) nodes
