{
  inputs,
  mylib,
  ...
} @ args: let
  name = "k3s-prod-1-master-1";
  tags = [name];
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
        {modules.secrets.server.kubernetes.enable = true;}
      ];
    home-modules = map mylib.relativeToRoot [
      "home/linux/server.nix"
    ];
  };

  systemArgs = modules // args;
in {
  nixosConfigurations.${name} = mylib.nixosSystem systemArgs;

  colmena.${name} =
    mylib.colmenaSystem (systemArgs // {inherit tags ssh-user;});

  # generate proxmox image for virtual machines without desktop environment
  packages.${name} = inputs.self.nixosConfigurations.${name}.config.formats.proxmox;
}
