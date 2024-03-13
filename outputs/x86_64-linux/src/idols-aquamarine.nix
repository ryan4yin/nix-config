{
  inputs,
  mylib,
  ...
} @ args: let
  # 星野 愛久愛海, Hoshino Akuamarin
  name = "aquamarine";
  tags = ["aqua" "homelab-network"];
  ssh-user = "root";

  modules = {
    nixos-modules =
      (map mylib.relativeToRoot [
        # common
        "secrets/nixos.nix"
        "modules/nixos/server/server.nix"
        "modules/nixos/server/proxmox-hardware-configuration.nix"
        # host specific
        "hosts/idols-${name}"
      ])
      ++ [
        {modules.secrets.server.network.enable = true;}
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
