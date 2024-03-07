args:
with args;
with mylib;
with allSystemAttrs; let
  # x86_64 related
  x64_base_args = {
    inherit home-manager;
    inherit nixpkgs; # or nixpkgs-unstable
    specialArgs = allSystemSpecialArgs.x64_system;
    targetUser = "root";
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
  rk3588_pkgs = import nixos-rk3588.inputs.nixpkgs {system = aarch64_system;};
  # aarch64 related
  rk3588_specialArgs = let
    # using the same nixpkgs as nixos-rk3588
    inherit (nixos-rk3588.inputs) nixpkgs;
    # use aarch64-linux's native toolchain
    pkgsKernel = import nixpkgs {
      system = aarch64_system;
    };
  in
    allSystemSpecialArgs.aarch64_system
    // {
      inherit nixpkgs;
      # Provide rk3588 inputs as special argument
      rk3588 = {inherit nixpkgs pkgsKernel;};
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
        rakushun = rk3588_specialArgs;
      };
      nodeNixpkgs = {
        nozomi = lpi4a_pkgs;
        yukina = lpi4a_pkgs;

        # aarch64 SBCs
        suzu = rk3588_pkgs;
        rakushun = rk3588_pkgs;
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

    k3s_prod_1_master_1 = colmenaSystem (attrs.mergeAttrsList [
      x64_base_args
      k3s_prod_1_master_1_modules
      {host_tags = k3s_prod_1_master_1_tags;}
    ]);
    k3s_prod_1_master_2 = colmenaSystem (attrs.mergeAttrsList [
      x64_base_args
      k3s_prod_1_master_2_modules
      {host_tags = k3s_prod_1_master_2_tags;}
    ]);
    k3s_prod_1_master_3 = colmenaSystem (attrs.mergeAttrsList [
      x64_base_args
      k3s_prod_1_master_3_modules
      {host_tags = k3s_prod_1_master_3_tags;}
    ]);
    k3s_prod_1_worker_1 = colmenaSystem (attrs.mergeAttrsList [
      x64_base_args
      k3s_prod_1_worker_1_modules
      {host_tags = k3s_prod_1_worker_1_tags;}
    ]);
    k3s_prod_1_worker_2 = colmenaSystem (attrs.mergeAttrsList [
      x64_base_args
      k3s_prod_1_worker_2_modules
      {host_tags = k3s_prod_1_worker_2_tags;}
    ]);
    k3s_prod_1_worker_3 = colmenaSystem (attrs.mergeAttrsList [
      x64_base_args
      k3s_prod_1_worker_3_modules
      {host_tags = k3s_prod_1_worker_3_tags;}
    ]);

    tailscale_gw = colmenaSystem (attrs.mergeAttrsList [
      x64_base_args
      homelab_tailscale_gw_modules
      {host_tags = homelab_tailscale_gw_tags;}
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
    rakushun = colmenaSystem (attrs.mergeAttrsList [
      rk3588_base_args
      _12kingdoms_rakushun_modules
      {host_tags = _12kingdoms_rakushun_tags;}
    ]);
  };
}
