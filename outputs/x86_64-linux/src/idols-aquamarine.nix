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
  # 星野 愛久愛海, Hoshino Akuamarin
  name = "aquamarine";
  tags = [
    name
    "homelab-ai"
  ];
  ssh-user = "root";

  modules = {
    nixos-modules =
      (map mylib.relativeToRoot [
        # profile: agent (hosts/README.md#host-profiles)
        "modules/nixos/agent.nix"
        # host specific
        "hosts/idols-${name}"
      ])
      ++ [
        # No `modules.secrets.server.*` group yet: the host would fail activation
        # until its new host key is a recipient in nix-secrets. Enabling one is
        # the last step in hosts/idols-aquamarine/README.md.
      ];
    home-modules = map mylib.relativeToRoot [
      # host specific
      "home/hosts/linux/idols-${name}.nix"
    ];
  };

  systemArgs = modules // args;
in
{
  nixosConfigurations.${name} = mylib.nixosSystem systemArgs;

  colmena.${name} = mylib.colmenaSystem (
    systemArgs
    // {
      inherit tags ssh-user;
    }
  );

  packages.${name} = inputs.self.nixosConfigurations.${name}.config.system.build.images.iso;
}
