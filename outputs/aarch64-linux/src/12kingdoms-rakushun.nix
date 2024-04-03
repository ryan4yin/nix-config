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
  # 楽俊, Rakushun
  name = "rakushun";
  tags = [name "aarch"];
  ssh-user = "root";

  modules = {
    nixos-modules =
      (map mylib.relativeToRoot [
        "secrets/nixos.nix"
        "modules/nixos/server/server-aarch64.nix"
        # host specific modules
        "hosts/12kingdoms-${name}"
      ])
      ++ [
        {modules.secrets.server.application.enable = true;}
        {modules.secrets.server.operation.enable = true;}
        {modules.secrets.server.webserver.enable = true;}
      ];
    home-modules = map mylib.relativeToRoot [
      "home/linux/tui.nix"
    ];
  };

  inherit (inputs) nixos-rk3588;
  baseSpecialArgs = genSpecialArgs system;

  rk3588Pkgs = import nixos-rk3588.inputs.nixpkgs {inherit system;};
  rk3588SpecialArgs = let
    # using the same nixpkgs as nixos-rk3588
    inherit (nixos-rk3588.inputs) nixpkgs;
    # use aarch64-linux's native toolchain
    pkgsKernel = import nixpkgs {inherit system;};
  in
    baseSpecialArgs
    // {
      inherit nixpkgs;
      # Provide rk3588 inputs as special argument
      rk3588 = {inherit nixpkgs pkgsKernel;};
    };

  rk3588SystemArgs =
    modules
    // args
    // {
      inherit (nixos-rk3588.inputs) nixpkgs; # or nixpkgs-unstable
      specialArgs = rk3588SpecialArgs;
    };
in {
  nixosConfigurations.${name} = mylib.nixosSystem rk3588SystemArgs;

  colmenaMeta = {
    nodeSpecialArgs.${name} = rk3588SpecialArgs;
    nodeNixpkgs.${name} = rk3588Pkgs;
  };
  colmena.${name} =
    mylib.colmenaSystem
    (rk3588SystemArgs // {inherit tags ssh-user;});
}
