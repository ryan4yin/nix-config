let
  _dekstop_bass_modules = {
    nixos-modules = [
      ../secrets/nixos.nix
      ../modules/nixos/desktop.nix
    ];
    home-module.imports = [
      ../home/linux/desktop.nix
    ];
  };

  desktop_i3_modules = {
    nixos-modules =
      [
        {modules.desktop.xorg.enable = true;}
      ]
      ++ _dekstop_bass_modules.nixos-modules;
    home-module.imports =
      [
        ../home/linux/desktop.nix
        {modules.desktop.i3.enable = true;}
      ]
      ++ _dekstop_bass_modules.home-module.imports;
  };
  desktop_hyprland_modules = {
    nixos-modules =
      [
        {modules.desktop.wayland.enable = true;}
      ]
      ++ _dekstop_bass_modules.nixos-modules;
    home-module.imports =
      [
        ../home/linux/desktop.nix
        {modules.desktop.hyprland.enable = true;}
      ]
      ++ _dekstop_bass_modules.home-module.imports;
  };
in rec {
  # 星野 アイ, Hoshino Ai
  idol_ai_modules_i3 = {
    nixos-modules =
      [
        ../hosts/idols/ai
      ]
      ++ desktop_i3_modules.nixos-modules;
    home-module = desktop_i3_modules.home-module;
  };

  idol_ai_modules_hyprland = {
    nixos-modules =
      [
        ../hosts/idols/ai
      ]
      ++ desktop_hyprland_modules.nixos-modules;
    home-module = desktop_hyprland_modules.home-module;
  };

  # 星野 愛久愛海, Hoshino Akuamarin
  idol_aquamarine_modules = {
    nixos-modules = [
      ../hosts/idols/aquamarine
      ../modules/nixos/server.nix
      ../modules/nixos/proxmox-hardware-configuration.nix
    ];
    home-module = import ../home/linux/server.nix;
  };
  idol_aquamarine_tags = ["dist-build" "aqua"];

  # 星野 瑠美衣, Hoshino Rubii
  idol_ruby_modules = {
    nixos-modules = [
      ../hosts/idols/ruby
      ../modules/nixos/server.nix
      ../modules/nixos/proxmox-hardware-configuration.nix
    ];
    home-module = import ../home/linux/server.nix;
  };
  idol_ruby_tags = ["dist-build" "ruby"];

  # 有馬 かな, Arima Kana
  idol_kana_modules = {
    nixos-modules = [
      ../hosts/idols/kana
      ../modules/nixos/server.nix
      ../modules/nixos/proxmox-hardware-configuration.nix
    ];
    home-module = import ../home/linux/server.nix;
  };
  idol_kana_tags = ["dist-build" "kana"];

  # 森友 望未, Moritomo Nozomi
  rolling_nozomi_modules = {
    nixos-modules = [
      ../hosts/rolling_girls/nozomi
      ../modules/nixos/server-riscv64.nix

      # cross-compilation this flake.
      {nixpkgs.crossSystem.system = "riscv64-linux";}
    ];
    # home-module = import ../home/linux/server.nix;
  };
  rolling_nozomi_tags = ["riscv" "nozomi"];

  # 小坂 結季奈, Kosaka Yukina
  rolling_yukina_modules = {
    nixos-modules = [
      ../hosts/rolling_girls/yukina
      ../modules/nixos/server-riscv64.nix

      # cross-compilation this flake.
      {nixpkgs.crossSystem.system = "riscv64-linux";}
    ];
    # home-module = import ../home/linux/server.nix;
  };
  rolling_yukina_tags = ["riscv" "yukina"];

  # 大木 鈴, Ōki Suzu
  _12kingdoms_suzu_modules = {
    nixos-modules = [
      ../hosts/12kingdoms/suzu
      ../modules/nixos/server-riscv64.nix

      # cross-compilation this flake.
      {nixpkgs.crossSystem.config = "aarch64-unknown-linux-gnu";}
    ];
    # home-module = import ../home/linux/server.nix;
  };
  _12kingdoms_suzu_tags = ["aarch" "suzu"];

  # Shoukei (祥瓊, Shōkei)
  _12kingdoms_shoukei_modules_i3 = {
    nixos-modules =
      [
        ../hosts/12kingdoms/shoukei
      ]
      ++ desktop_i3_modules.nixos-modules;
    home-module = desktop_i3_modules.home-module;
  };

  _12kingdoms_shoukei_modules_hyprland = {
    nixos-modules =
      [
        ../hosts/12kingdoms/shoukei
      ]
      ++ desktop_hyprland_modules.nixos-modules;
    home-module = desktop_hyprland_modules.home-module;
  };

  # darwin systems
  darwin_harmonica_modules = {
    darwin-modules = [
      ../hosts/harmonica

      ../modules/darwin
      ../secrets/darwin.nix
    ];
    home-module = import ../home/darwin;
  };
  darwin_fern_modules = {
    darwin-modules = [
      ../hosts/fern

      ../modules/darwin
      ../secrets/darwin.nix
    ];
    home-module = import ../home/darwin;
  };
}
