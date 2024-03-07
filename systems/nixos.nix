args:
with args;
with mylib;
with allSystemAttrs; let
  base_args = {
    inherit home-manager nixos-generators;
    inherit nixpkgs; # or nixpkgs-unstable
    system = x64_system;
    specialArgs = allSystemSpecialArgs.x64_system;
  };

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
    inherit home-manager nixos-generators;
    inherit (nixos-rk3588.inputs) nixpkgs; # or nixpkgs-unstable
    system = aarch64_system;
    specialArgs = rk3588_specialArgs;
  };
in {
  nixosConfigurations = {
    # ai with i3 window manager
    ai_i3 = nixosSystem (idol_ai_modules_i3 // base_args);
    # ai with hyprland compositor
    ai_hyprland = nixosSystem (idol_ai_modules_hyprland // base_args);

    # shoukei
    shoukei_i3 = nixosSystem (_12kingdoms_shoukei_modules_i3 // base_args);
    shoukei_hyprland = nixosSystem (_12kingdoms_shoukei_modules_hyprland // base_args);

    # three virtual machines without desktop environment.
    aquamarine = nixosSystem (idol_aquamarine_modules // base_args);
    ruby = nixosSystem (idol_ruby_modules // base_args);
    kana = nixosSystem (idol_kana_modules // base_args);

    k3s_prod_1_master_1 = nixosSystem (k3s_prod_1_master_1_modules // base_args);
    k3s_prod_1_master_2 = nixosSystem (k3s_prod_1_master_2_modules // base_args);
    k3s_prod_1_master_3 = nixosSystem (k3s_prod_1_master_3_modules // base_args);
    k3s_prod_1_worker_1 = nixosSystem (k3s_prod_1_worker_1_modules // base_args);
    k3s_prod_1_worker_2 = nixosSystem (k3s_prod_1_worker_2_modules // base_args);
    k3s_prod_1_worker_3 = nixosSystem (k3s_prod_1_worker_3_modules // base_args);

    tailscale_gw = nixosSystem (homelab_tailscale_gw_modules // base_args);

    # aarch64 hosts
    suzu = nixosSystem (_12kingdoms_suzu_modules // rk3588_base_args);
    rakushun = nixosSystem (_12kingdoms_rakushun_modules // rk3588_base_args);
  };

  # https://github.com/nix-community/nixos-generators
  packages."${x64_system}" = attrs.mergeAttrsList [
    (
      attrs.listToAttrs
      [
        "ai_i3"
        "ai_hyprland"
      ]
      # generate iso image for hosts with desktop environment
      (host: self.nixosConfigurations.${host}.config.formats.iso)
    )

    (
      attrs.listToAttrs
      [
        "aquamarine"
        "ruby"
        "kana"

        "k3s_prod_1_master_1"
        "k3s_prod_1_master_2"
        "k3s_prod_1_master_3"
        "k3s_prod_1_worker_1"
        "k3s_prod_1_worker_2"
        "k3s_prod_1_worker_3"

        "tailscale_gw"
      ]
      # generate proxmox image for virtual machines without desktop environment
      (host: self.nixosConfigurations.${host}.config.formats.proxmox)
    )
  ];
}
