{ config, niri, ... }:
let
  hostName = "shoukei"; # Define your hostname.
in
{
  programs.ssh.matchBlocks."github.com".identityFile =
    "${config.home.homeDirectory}/.ssh/${hostName}";

  modules.desktop.nvidia.enable = false;
  modules.desktop.hyprland.settings.source = [
    "${config.home.homeDirectory}/nix-config/hosts/12kingdoms-shoukei/hypr-hardware.conf"
  ];

  modules.desktop.niri = {
    settings =
      let
        inherit (niri.lib.kdl)
          node
          plain
          leaf
          flag
          ;
      in
      [
        (node "output" "eDP-1" [
          (leaf "scale" 1.5)
          (leaf "transform" "normal")
          (leaf "mode" "2560x1600@60")
          (leaf "position" {
            x = 0;
            y = 0;
          })
        ])

        # ============= Named Workspaces =============
        (node "workspace" "1terminal" [ (leaf "open-on-output" "eDP-1") ])
        (node "workspace" "2browser" [ (leaf "open-on-output" "eDP-1") ])
        (node "workspace" "3chat" [ (leaf "open-on-output" "eDP-1") ])
        (node "workspace" "4music" [ (leaf "open-on-output" "eDP-1") ])
        (node "workspace" "5mail" [ (leaf "open-on-output" "eDP-1") ])
        (node "workspace" "6file" [ (leaf "open-on-output" "eDP-1") ])
        (node "workspace" "0other" [ (leaf "open-on-output" "eDP-1") ])

        # Settings for debugging. Not meant for normal use.
        # These can change or stop working at any point with little notice.
        (plain "debug" [
          # Override the DRM device that niri will use for all rendering.
          # Fix: niri fails to correctly detect the primary render device
          (leaf "render-drm-device" "/dev/dri/renderD128")
        ])
      ];
  };

}
