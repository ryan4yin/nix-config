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
} @ args: let
  name = "kubevirt-youko";
  tags = [name "virt-youko"];
  ssh-user = "root";

  modules = {
    nixos-modules =
      (map mylib.relativeToRoot [
        # common
        "secrets/nixos.nix"
        "modules/nixos/server/server.nix"
        # host specific
        "hosts/k8s/${name}"
      ])
      ++ [
        {
          modules.secrets.server.kubernetes.enable = true;
          modules.secrets.preservation.enable = true;
        }
      ];
  };

  systemArgs = modules // args;
in {
  nixosConfigurations.${name} = mylib.nixosSystem systemArgs;

  colmena.${name} =
    mylib.colmenaSystem (systemArgs // {inherit tags ssh-user;});

  packages.${name} = inputs.self.nixosConfigurations.${name}.config.formats.iso;
}
