{pkgs, ...}:


{
  # i3wm: old and stable, only support X11
  # sway: compatible with i3wm, support Wayland. do not support Nvidia GPU officially.
  # hyprland: project starts from 2022, support Wayland, envolving fast, good looking, support Nvidia GPU.

  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw
  services.xserver = {
    enable = true;

    desktopManager = {
      xterm.enable = false;
    };

    displayManager = {
        defaultSession = "hyprland";
        lightdm.enable = false;
        gdm.enable = true;
    };
  };

  programs.hyprland = {
    enable = true;

    xwayland = {
      enable = true;
      hidpi = true;
    };

    nvidiaPatches = true;
  };


  # thunar file manager(part of xfce) related options
  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  
}
