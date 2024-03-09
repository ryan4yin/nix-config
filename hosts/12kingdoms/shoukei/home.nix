{
  modules.desktop.hyprland = {
    nvidia = false;
    settings = {
      # Configure your Display resolution, offset, scale and Monitors here, use `hyprctl monitors` to get the info.
      #   highres:      get the best possible resolution
      #   auto:         postition automatically
      #   1.5:          scale to 1.5 times
      #   bitdepth,10:  enable 10 bit support
      monitor = "eDP-1,highres,auto,1.5,bitdepth,10";
    };
  };

  modules.desktop.i3 = {
    nvidia = false;
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host github.com
        Hostname github.com
        # github is controlled by shoukei~
        IdentityFile ~/.ssh/shoukei
        # Specifies that ssh should only use the identity file explicitly configured above
        # required to prevent sending default identity files first.
        IdentitiesOnly yes
    '';
  };
}
