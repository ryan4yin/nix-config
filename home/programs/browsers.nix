{
  pkgs,
  nixpkgs-stable,
  config,
  ...
}: let
  pkgs-stable = import nixpkgs-stable {
    system = pkgs.system;
    config.allowUnfree = true;
  };
  in {
  home.packages = with pkgs-stable; [
    firefox-wayland
    # firefox
  ];

  programs = {

    # source code: https://github.com/nix-community/home-manager/blob/master/modules/programs/chromium.nix
    google-chrome = {
      enable = true;

      # chrome wayland support was broken on nixos-unstable branch, so fallback to stable branch for now
      # https://github.com/swaywm/sway/issues/7562
      package = pkgs-stable.google-chrome;

      commandLineArgs = [
        # make it use GTK_IM_MODULE if it runs with Gtk4, so fcitx5 can work with it.
        # (only supported by chromium/chrome at this time, not electron) 
        "--gtk-version=4"
        # make it use text-input-v1, which works for kwin 5.27 and weston
        # "--enable-wayland-ime"

        # enable hardware acceleration - vulkan api
        # "--enable-features=Vulkan"
      ];
    };

    vscode = {
      enable = true;
      # use the stable version
      package = pkgs-stable.vscode.override {
        commandLineArgs = [
          # make it use text-input-v1, which works for kwin 5.27 and weston
          # "--enable-wayland-ime"
        ];
      };

      # let vscode sync and update its configuration & extensions across devices, using github account.
      # userSettings = {};
    };
    

    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/web-apps/code-server.nix
    
  };
}
