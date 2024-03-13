{
  inputs,
  mylib,
  system,
  genSpecialArgs,
  ...
} @ args: let
  # 小坂 結季奈, Kosaka Yukina
  name = "yukina";
  tags = [name "riscv"];
  ssh-user = "root";

  modules = {
    nixos-modules =
      (map mylib.relativeToRoot [
        "modules/nixos/server/server-riscv64.nix"
        # host specific modules
        "hosts/rolling-girls-${name}"
      ])
      ++ [
        # cross-compilation this flake.
        {nixpkgs.crossSystem.system = "riscv64-linux";}
      ];
  };

  inherit (inputs) nixos-licheepi4a;
  baseSpecialArgs = genSpecialArgs system;

  # using the same nixpkgs as nixos-licheepi4a to utilize the cross-compilation cache.
  lpi4aPkgs = import nixos-licheepi4a.inputs.nixpkgs {inherit system;};
  lpi4aSpecialArgs =
    baseSpecialArgs
    // {
      inherit (nixos-licheepi4a.inputs) nixpkgs;
      pkgsKernel = nixos-licheepi4a.packages.${system}.pkgsKernelCross;
    }
    // args;
  lpi4aSystemArgs =
    modules
    // args
    // {
      inherit (nixos-licheepi4a.inputs) nixpkgs;
      specialArgs = lpi4aSpecialArgs;
    };
in {
  nixosConfigurations.${name} = mylib.nixosSystem lpi4aSystemArgs;

  colmena-meta = {
    nodeSpecialArgs.${name} = lpi4aSpecialArgs;
    nodeNixpkgs.${name} = lpi4aPkgs;
  };
  colmena.${name} =
    mylib.colmenaSystem
    (lpi4aSystemArgs // {inherit tags ssh-user;});
}
