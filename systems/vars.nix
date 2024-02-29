let
  desktop_base_modules = {
    nixos-modules = [
      ../secrets/nixos.nix
      ../modules/nixos/desktop.nix
    ];
    home-module.imports = [
      ../home/linux/desktop.nix
    ];
  };

  pve_base_modules = {
    nixos-modules = [
      ../secrets/nixos.nix
      ../modules/nixos/server/server.nix
      ../modules/nixos/server/proxmox-hardware-configuration.nix
    ];
  };
  kube_base_modules = {
    nixos-modules = [
      ../secrets/nixos.nix
      ../modules/nixos/server/server.nix
      ../modules/nixos/server/proxmox-hardware-configuration.nix
      {modules.secrets.server.kubernetes.enable = true;}
    ];
  };
in {
  # --- Desktop Systems --- #

  # 星野 アイ, Hoshino Ai
  idol_ai_modules_i3 = {
    nixos-modules =
      [
        ../hosts/idols_ai
        {
          modules.desktop.xorg.enable = true;
          modules.secrets.desktop.enable = true;
          modules.secrets.impermanence.enable = true;
        }
      ]
      ++ desktop_base_modules.nixos-modules;
    home-module.imports =
      [
        ../hosts/idols_ai/home.nix
        {modules.desktop.i3.enable = true;}
      ]
      ++ desktop_base_modules.home-module.imports;
  };

  idol_ai_modules_hyprland = {
    nixos-modules =
      [
        ../hosts/idols_ai
        {
          modules.desktop.wayland.enable = true;
          modules.secrets.desktop.enable = true;
          modules.secrets.impermanence.enable = true;
        }
      ]
      ++ desktop_base_modules.nixos-modules;
    home-module.imports =
      [
        ../hosts/idols_ai/home.nix
        {modules.desktop.hyprland.enable = true;}
      ]
      ++ desktop_base_modules.home-module.imports;
  };

  # --- Homelab Systems --- #

  # 星野 愛久愛海, Hoshino Akuamarin
  idol_aquamarine_modules = {
    nixos-modules =
      [
        ../hosts/idols_aquamarine
        ../modules/nixos/server/proxmox-hardware-configuration.nix
        {modules.secrets.server.network.enable = true;}
      ]
      ++ pve_base_modules.nixos-modules;
    # home-module.imports = [];
  };
  idol_aquamarine_tags = ["aqua" "homelab-network"];

  # 星野 瑠美衣, Hoshino Rubii
  idol_ruby_modules = {
    nixos-modules =
      [
        ../hosts/idols_ruby
        {modules.secrets.server.operation.enable = true;}
      ]
      ++ pve_base_modules.nixos-modules;
    home-module.imports = [
      ../home/linux/server.nix
    ];
  };
  idol_ruby_tags = ["ruby" "homelab-operation"];

  # 有馬 かな, Arima Kana
  idol_kana_modules = {
    nixos-modules =
      [
        ../hosts/idols_kana
        {modules.secrets.server.application.enable = true;}
      ]
      ++ pve_base_modules.nixos-modules;
    # home-module.imports = [];
  };
  idol_kana_tags = ["kana" "homelab-app"];

  homelab_tailscale_gw_modules = {
    nixos-modules =
      [
        ../hosts/homelab_tailscale_gw
      ]
      ++ pve_base_modules.nixos-modules;
    # home-module.imports = [];
  };
  homelab_tailscale_gw_tags = ["tailscale-gw" "homelab-network"];

  # --- Kubernetes Nodes --- #

  k3s_prod_1_master_1_modules = {
    nixos-modules =
      [
        ../hosts/k8s/k3s_prod_1_master_1
      ]
      ++ kube_base_modules.nixos-modules;
    home-module.imports = [
      ../home/linux/server.nix
    ];
  };
  k3s_prod_1_master_1_tags = ["k8s-prod-master"];

  k3s_prod_1_master_2_modules = {
    nixos-modules =
      [
        ../hosts/k8s/k3s_prod_1_master_2
      ]
      ++ kube_base_modules.nixos-modules;
  };
  k3s_prod_1_master_2_tags = ["k8s-prod-master"];

  k3s_prod_1_master_3_modules = {
    nixos-modules =
      [
        ../hosts/k8s/k3s_prod_1_master_3
      ]
      ++ kube_base_modules.nixos-modules;
  };
  k3s_prod_1_master_3_tags = ["k8s-prod-master"];

  k3s_prod_1_worker_1_modules = {
    nixos-modules =
      [
        ../hosts/k8s/k3s_prod_1_worker_1
      ]
      ++ kube_base_modules.nixos-modules;
  };
  k3s_prod_1_worker_1_tags = ["k8s-prod-worker"];

  k3s_prod_1_worker_2_modules = {
    nixos-modules =
      [
        ../hosts/k8s/k3s_prod_1_worker_2
      ]
      ++ kube_base_modules.nixos-modules;
  };
  k3s_prod_1_worker_2_tags = ["k8s-prod-worker"];

  k3s_prod_1_worker_3_modules = {
    nixos-modules =
      [
        ../hosts/k8s/k3s_prod_1_worker_3
      ]
      ++ kube_base_modules.nixos-modules;
  };
  k3s_prod_1_worker_3_tags = ["k8s-prod-worker"];

  # --- RISC-V / AARCH64 Systems --- #

  # 森友 望未, Moritomo Nozomi
  rolling_nozomi_modules = {
    nixos-modules = [
      ../hosts/rolling_girls_nozomi
      ../modules/nixos/server/server-riscv64.nix

      # cross-compilation this flake.
      {nixpkgs.crossSystem.system = "riscv64-linux";}
    ];
    # home-module.imports = [];
  };
  rolling_nozomi_tags = ["riscv" "nozomi"];

  # 小坂 結季奈, Kosaka Yukina
  rolling_yukina_modules = {
    nixos-modules = [
      ../hosts/rolling_girls_yukina
      ../modules/nixos/server/server-riscv64.nix

      # cross-compilation this flake.
      {nixpkgs.crossSystem.system = "riscv64-linux";}
    ];
    # home-module.imports = [];
  };
  rolling_yukina_tags = ["riscv" "yukina"];

  # 大木 鈴, Ōki Suzu
  _12kingdoms_suzu_modules = {
    nixos-modules = [
      ../hosts/12kingdoms_suzu
      ../modules/nixos/server/server-riscv64.nix

      # cross-compilation this flake.
      {nixpkgs.crossSystem.config = "aarch64-unknown-linux-gnu";}
    ];
    # home-module.imports = [];
  };
  _12kingdoms_suzu_tags = ["aarch" "suzu"];

  # Shoukei (祥瓊, Shōkei)
  _12kingdoms_shoukei_modules_i3 = {
    nixos-modules =
      [
        ../hosts/12kingdoms_shoukei
        {modules.desktop.xorg.enable = true;}
      ]
      ++ desktop_base_modules.nixos-modules;
    home-module.imports =
      [
        ../hosts/12kingdoms_shoukei/home.nix
        {modules.desktop.i3.enable = true;}
      ]
      ++ desktop_base_modules.home-module.imports;
  };

  _12kingdoms_shoukei_modules_hyprland = {
    nixos-modules =
      [
        ../hosts/12kingdoms_shoukei
        {modules.desktop.wayland.enable = true;}
      ]
      ++ desktop_base_modules.nixos-modules;
    home-module.imports =
      [
        ../hosts/12kingdoms_shoukei/home.nix
        {modules.desktop.hyprland.enable = true;}
      ]
      ++ desktop_base_modules.home-module.imports;
  };

  # --- Darwin Systems --- #
  darwin_harmonica_modules = {
    darwin-modules = [
      ../hosts/darwin_harmonica

      ../modules/darwin
      ../secrets/darwin.nix
    ];
    home-module.imports = [
      ../hosts/darwin_harmonica/home.nix
      ../home/darwin
    ];
  };
  darwin_fern_modules = {
    darwin-modules = [
      ../hosts/darwin_fern

      ../modules/darwin
      ../secrets/darwin.nix
    ];
    home-module.imports = [
      ../hosts/darwin_fern/home.nix
      ../home/darwin
    ];
  };
}
