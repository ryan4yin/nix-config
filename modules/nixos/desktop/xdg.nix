{ pkgs, ... }:
{
  xdg.terminal-exec = {
    enable = true;
    package = pkgs.xdg-terminal-exec-mkhl;
    settings =
      let
        my_terminal_desktop = [
          # NOTE: We have add these packages at user level
          "Alacritty.desktop"
          "kitty.desktop"
          "foot.desktop"
          "com.mitchellh.ghostty.desktop"
        ];
      in
      {
        GNOME = my_terminal_desktop ++ [
          "com.raggesilver.BlackBox.desktop"
          "org.gnome.Terminal.desktop"
        ];
        niri = my_terminal_desktop;
        default = my_terminal_desktop;
      };
  };

  xdg.portal = {
    enable = true;

    config = {
      common = {
        # Use xdg-desktop-portal-gtk for every portal interface...
        default = [
          "gtk"
        ];
        # except for the secret portal, which is handled by gnome-keyring
        "org.freedesktop.impl.portal.Secret" = [
          "gnome-keyring"
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

    # ls /run/current-system/sw/share/xdg-desktop-portal/portals/
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk # for provides file picker / OpenURI
    ];
  };
}
