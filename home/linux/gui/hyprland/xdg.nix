{ pkgs, ... }:
{
  xdg.portal = {
    enable = true;

    config = {
      common = {
        # Use xdg-desktop-portal-gtk for every portal interface...
        default = [
          "hyprland"
          "gtk"
        ];
      };
    };

    # Sets environment variable NIXOS_XDG_OPEN_USE_PORTAL to 1
    # This will make xdg-open use the portal to open programs,
    # which resolves bugs involving programs opening inside FHS envs or with unexpected env vars set from wrappers.
    # xdg-open is used by almost all programs to open a unknown file/uri
    # alacritty as an example, it use xdg-open as default, but you can also custom this behavior
    # and vscode has open like `External Uri Openers`
    xdgOpenUsePortal = true;
    # ls /etc/profiles/per-user/ryan/share/xdg-desktop-portal/portals
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk # for provides file picker / OpenURI
      # xdg-desktop-portal-wlr
      xdg-desktop-portal-hyprland # for Hyprland
    ];
  };
}
