{
  inputs,
  mylib,
  ...
} @ args: let
  name = "kubevirt-shoryu";
  tags = [name "virt-shoryu"];
  ssh-user = "root";

  modules = {
    nixos-modules =
      (map mylib.relativeToRoot [
        # common
        "secrets/nixos.nix"
        "modules/nixos/server/server.nix"
        "modules/nixos/server/proxmox-hardware-configuration.nix"
        # host specific
        "hosts/k8s/${name}"
      ])
      ++ [
        # {modules.secrets.server.kubernetes.enable = true;}
      ];
  };

  systemArgs = modules // args;
in {
  nixosConfigurations.${name} = mylib.nixosSystem systemArgs;

  colmena.${name} =
    mylib.colmenaSystem (systemArgs // {inherit tags ssh-user;});

  packages.${name} = inputs.self.nixosConfigurations.${name}.config.formats.iso;
}
