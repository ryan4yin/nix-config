{
  modules.desktop = {
    hyprland = {
      nvidia = true;
      settings = {
        # Configure your Display resolution, offset, scale and Monitors here, use `hyprctl monitors` to get the info.
        #   highres:      get the best possible resolution
        #   auto:         position automatically
        #   1.5:          scale to 1.5 times
        #   bitdepth,10:  enable 10 bit support
        monitor = "DP-2,highres,auto,1.5,bitdepth,10";
      };
    };
    i3.nvidia = true;
  };
  modules.editors.emacs = {
    enable = true;
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host github.com
          IdentityFile ~/.ssh/idols-ai
          # Specifies that ssh should only use the identity file explicitly configured above
          # required to prevent sending default identity files first.
          IdentitiesOnly yes
    '';
  };
}
