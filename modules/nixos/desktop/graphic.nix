{pkgs, ...}: {
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
    xdgOpenUsePortal = false;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk # for gtk
      # xdg-desktop-portal-kde  # for kde
    ];
  };
}
