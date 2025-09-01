{
  pkgs-unstable,
  nixos-apple-silicon,
  my-asahi-firmware,
  ...
}:
{
  imports = [
    nixos-apple-silicon.nixosModules.default
  ];

  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };
  # configures the network interface(include wireless) via `nmcli` & `nmtui`
  networking.networkmanager.enable = true;

  # Specify path to peripheral firmware files.
  hardware.asahi = {
    enable = true;
    peripheralFirmwareDirectory = "${my-asahi-firmware}/macbook-pro-m2-a2338";

    # since mesa 25.1(already in nixpkgs), support for asahi is enabled by default.
  };

  # Lid & PowerKey settings
  #
  # Suspend: Store system state to RAM - fast, requires minimal power to maintain RAM.
  # Hibernate: Store system state & RAM to Disk, and then poweroff the system.
  #
  # NOTE: Hibernate is not supported by Asahi Linux.
  services.logind.settings.Login = {
    lidSwitch = "suspend";
    lidSwitchExternalPower = "lock";
    # 'Docked' means: more than one display is connected or the system is inserted in a docking station
    lidSwitchDocked = "ignore";

    powerKey = "suspend";
    powerKeyLongPress = "poweroff";
  };
  systemd.targets.sleep.enable = true;
  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernate=no
    AllowSuspendThenHibernate=no
    HibernateDelaySec=5min
  '';

  # After adding this snippet, you need to restart the system for the touchbar to work.
  hardware.apple.touchBar = {
    enable = true;
    package = pkgs-unstable.tiny-dfr;
    # https://github.com/WhatAmISupposedToPutHere/tiny-dfr/blob/master/share/tiny-dfr/config.toml
    settings = {
      # F{number} keys are shown when Fn is not pressed by default.
      # Set this to true if you want the media keys to be shown without Fn pressed
      MediaLayerDefault = true;

      # Set this to false if you want to hide the button outline,
      # leaving only the text/logo
      ShowButtonOutlines = true;

      # Set this to true to slowly shift the entire screen contents.
      # In theory this helps with screen longevity, but macos does not bother doing it
      # Disabling ShowButtonOutlines will make this effect less noticeable to the eye
      EnablePixelShift = true;

      # This key defines the contents of the primary layer
      # (the one with F{number} keys)
      # You can change the individual buttons, add, or remove them
      # Any number of keys that is greater than 0 is allowed
      # however rendering will start to break around 24 keys
      # Buttons can be made larger by setting the optional Stretch field
      # to a number greater than 1 (which means the button will take up
      # that many button spaces).
      PrimaryLayerKeys = [
        # Action defines the key code to send when the button is pressed
        # Text defines the button label
        # Icon specifies the icon to be used for the button.
        # Theme specifies the XDG icons theme.
        # Stretch specifies how many button spaces the button should take up
        # and defaults to 1
        # Icons can either be svgs or pngs, with svgs being preferred
        # For best results with pngs, they should be 48x48
        # Do not include the extension in the file name.
        # If a Theme is set, icons are looked up in XDG_DATA_DIRS.
        # Otherwise, they are first looked up in /etc/tiny-dfr, and then in /usr/share/tiny-dfr.
        # Time can be either 24hr, or 12hr. Locale is optional and will default to POSIX.
        # Only one of Text, Icon or Time is allowed,
        # if both are present, the behavior is undefined.
        # For the list of supported key codes see
        # https://docs.rs/input-linux/latest/input_linux/enum.Key.html
        # Note that the escape key is not specified here, as it is added
        # automatically on Macs without a physical one
        {
          Text = "F1";
          Action = "F1";
        }
        {
          Text = "F2";
          Action = "F2";
        }
        {
          Text = "F3";
          Action = "F3";
        }
        {
          Text = "F4";
          Action = "F4";
        }
        {
          Text = "F5";
          Action = "F5";
        }
        {
          Text = "F6";
          Action = "F6";
        }
        {
          Text = "F7";
          Action = "F7";
        }
        {
          Text = "F8";
          Action = "F8";
        }
        {
          Text = "F9";
          Action = "F9";
        }
        {
          Text = "F10";
          Action = "F10";
        }
        {
          Text = "F11";
          Action = "F11";
        }
        {
          Text = "F12";
          Action = "F12";
        }

        {
          Text = "Home";
          Action = "Home";
        }
        {
          Text = "End";
          Action = "End";
        }

        # for screenshot shortcut
        {
          Text = "Print";
          Action = "Print";
        }
      ];

      # This key defines the contents of the media key layer
      MediaLayerKeys = [
        {
          Icon = "brightness_low";
          Action = "BrightnessDown";
        }
        {
          Icon = "brightness_high";
          Action = "BrightnessUp";
        }
        {
          Icon = "mic_off";
          Action = "MicMute";
        }
        {
          Icon = "search";
          Action = "Search";
        }
        {
          Icon = "backlight_low";
          Action = "IllumDown";
        }
        {
          Icon = "backlight_high";
          Action = "IllumUp";
        }
        {
          Icon = "fast_rewind";
          Action = "PreviousSong";
        }
        {
          Icon = "play_pause";
          Action = "PlayPause";
        }
        {
          Icon = "fast_forward";
          Action = "NextSong";
        }
        {
          Icon = "volume_off";
          Action = "Mute";
        }
        {
          Icon = "volume_down";
          Action = "VolumeDown";
        }
        {
          Icon = "volume_up";
          Action = "VolumeUp";
        }

        {
          Text = "Home";
          Action = "Home";
        }
        {
          Text = "End";
          Action = "End";
        }

        # for screenshot shortcut
        {
          Text = "Print";
          Action = "Print";
        }
      ];
    };
  };

  # For ` to < and ~ to > (for those with US keyboards)
  # boot.extraModprobeConfig = ''
  #   options hid_apple iso_layout=0
  # '';
}
