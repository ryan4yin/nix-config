{
  # NOTE: the args not used in this file CAN NOT be removed!
  # because haumea pass argument lazily,
  # and these arguments are used in the functions like `mylib.nixosSystem`, `mylib.colmenaSystem`, etc.
  inputs,
  lib,
  mylib,
  myvars,
  system,
  genSpecialArgs,
  ...
}@args:
let
  name = "k3s-test-1-master-2";
  tags = [ name ];
  ssh-user = "root";

  modules = {
    # the host dir is the complete config (it pulls in the shared modules)
    nixos-modules =
      (map mylib.relativeToRoot [
        "hosts/k8s/${name}"
      ])
      ++ [
        # this runs as a MicroVM
        inputs.microvm.nixosModules.microvm
        { modules.secrets.server.kubernetes.enable = true; }
      ];
  };

  systemArgs = modules // args;
in
{
  nixosConfigurations.${name} = mylib.nixosSystem systemArgs;

  colmena.${name} = mylib.colmenaSystem (systemArgs // { inherit tags ssh-user; });
}
