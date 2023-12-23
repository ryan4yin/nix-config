{pkgs, ...}: {
  ####################################################################
  #
  #  NixOS's Configuration for Xorg Server
  #
  ####################################################################

  imports = [
    ./base/i18n.nix
    ./base/misc.nix
    ./base/networking.nix
    ./base/remote-building.nix
    ./base/user-group.nix
    ./base/visualisation.nix

    ./desktop
    ../base.nix
  ];

  services = {
    gvfs.enable = true; # Mount, trash, and other functionalities
    tumbler.enable = true; # Thumbnail support for images

    xserver = {
      enable = true;
      displayManager = {
        lightdm.enable = true;
        autoLogin = {
          enable = true;
          user = "ryan";
        };
        # use a fake session to skip desktop manager
        # and let Home Manager take care of the X session
        defaultSession = "hm-session";
      };
      desktopManager = {
        runXdgAutostartIfNone = true;
        session = [
          {
            name = "hm-session";
            manage = "window";
            start = ''
              ${pkgs.runtimeShell} $HOME/.xsession &
              waitPID=$!
            '';
          }
        ];
      };
      # Configure keymap in X11
      xkb.layout = "us";
    };
  };
}
