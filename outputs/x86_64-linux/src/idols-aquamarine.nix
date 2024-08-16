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
        "modules/nixos/server/kubevirt-hardware-configuration.nix"
        # host specific
        "hosts/idols-${name}"
      ])
      ++ [
        {modules.secrets.server.application.enable = true;}
        {modules.secrets.server.operation.enable = true;}
        {modules.secrets.server.webserver.enable = true;}
        {modules.secrets.server.storage.enable = true;}
      ];
    home-modules = map mylib.relativeToRoot [
      "home/linux/tui.nix"
    ];
  };

  systemArgs = modules // args;
in {
  nixosConfigurations.${name} = mylib.nixosSystem systemArgs;

  colmena.${name} =
    mylib.colmenaSystem (systemArgs // {inherit tags ssh-user;});

  packages.${name} = inputs.self.nixosConfigurations.${name}.config.formats.kubevirt;
}
