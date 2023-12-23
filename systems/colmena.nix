args:
with args;
with mylib;
with allSystemAttrs; let
  # x86_64 related
  x64_base_args = {
    inherit home-manager;
    inherit nixpkgs; # or nixpkgs-unstable
    specialArgs = allSystemSpecialArgs.x64_system;
  };

  # riscv64 related
  # using the same nixpkgs as nixos-licheepi4a to utilize the cross-compilation cache.
  lpi4a_pkgs = import nixos-licheepi4a.inputs.nixpkgs {system = x64_system;};
  lpi4a_specialArgs =
    {
      inherit username userfullname useremail;
      pkgsKernel = nixos-licheepi4a.packages.${x64_system}.pkgsKernelCross;
    }
    // args;
  lpi4a_base_args = {
    inherit home-manager;
    inherit (nixos-licheepi4a.inputs) nixpkgs; # or nixpkgs-unstable
    specialArgs = lpi4a_specialArgs;
    targetUser = "root";
  };

  # aarch64 related
  # using the same nixpkgs as nixos-rk3588 to utilize the cross-compilation cache.
  rk3588_pkgs = import nixos-rk3588.inputs.nixpkgs {system = x64_system;};
  rk3588_specialArgs = {
    inherit username userfullname useremail;
    inherit (nixos-rk3588.inputs) nixpkgs;
    # Provide rk3588 inputs as special argument
    rk3588 = nixos-rk3588.inputs;
  };
  rk3588_base_args = {
    inherit home-manager;
    inherit (nixos-rk3588.inputs) nixpkgs; # or nixpkgs-unstable
    specialArgs = rk3588_specialArgs;
    targetUser = "root";
  };
in {
  # colmena - remote deployment via SSH
  colmena = {
    meta = {
      nixpkgs = import nixpkgs {system = x64_system;};
      specialArgs = allSystemSpecialArgs.x64_system;

      nodeSpecialArgs = {
        # riscv64 SBCs
        nozomi = lpi4a_specialArgs;
        yukina = lpi4a_specialArgs;

        # aarch64 SBCs
        suzu = rk3588_specialArgs;
      };
      nodeNixpkgs = {
        nozomi = lpi4a_pkgs;
        yukina = lpi4a_pkgs;

        # aarch64 SBCs
        suzu = rk3588_pkgs;
      };
    };

    # proxmox virtual machines(x86_64)
    aquamarine = colmenaSystem (attrs.mergeAttrsList [
      x64_base_args
      idol_aquamarine_modules
      {host_tags = idol_aquamarine_tags;}
    ]);
    ruby = colmenaSystem (attrs.mergeAttrsList [
      x64_base_args
      idol_ruby_modules
      {host_tags = idol_ruby_tags;}
    ]);
    kana = colmenaSystem (attrs.mergeAttrsList [
      x64_base_args
      idol_kana_modules
      {host_tags = idol_kana_tags;}
    ]);

    # riscv64 SBCs
    nozomi = colmenaSystem (attrs.mergeAttrsList [
      lpi4a_base_args
      rolling_nozomi_modules
      {host_tags = rolling_nozomi_tags;}
    ]);
    yukina = colmenaSystem (attrs.mergeAttrsList [
      lpi4a_base_args
      rolling_yukina_modules
      {host_tags = rolling_yukina_tags;}
    ]);

    # aarch64 SBCs
    suzu = colmenaSystem (attrs.mergeAttrsList [
      rk3588_base_args
      _12kingdoms_suzu_modules
      {host_tags = _12kingdoms_suzu_tags;}
    ]);
  };
}
