{
  inputs,
  mylib,
  system,
  genSpecialArgs,
  ...
} @ args: let
  # 大木 鈴, Ōki Suzu
  name = "suzu";
  tags = [name "aarch"];
  ssh-user = "root";

  modules = {
    nixos-modules = map mylib.relativeToRoot [
      "modules/nixos/server/server-aarch64.nix"
      # host specific modules
      "hosts/12kingdoms-${name}"
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

  colmena-meta = {
    nodeSpecialArgs.${name} = rk3588SpecialArgs;
    nodeNixpkgs.${name} = rk3588Pkgs;
  };
  colmena.${name} =
    mylib.colmenaSystem
    (rk3588SystemArgs // {inherit tags ssh-user;});
}
