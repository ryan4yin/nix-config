{
  lib,
  pkgs,
  nixos-apple-silicon,
  my-asahi-firmware,
  ...
}:
{
  imports = [
    nixos-apple-silicon.nixosModules.default
  ];

  # NOTE: do NOT autologin here (a bare session command = greetd restarts the desktop
  # without any authentication whenever the session exits, e.g. logout from the lock
  # screen would bypass it entirely). Keep tuigreet from modules/nixos/desktop.nix.

  # 16G machine: more compressed swap than the 50% default
  zramSwap.memoryPercent = lib.mkForce 75;

  nix.settings = {
    extra-substituters = [
      "https://nixos-apple-silicon.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
    ];
  };

  # configures the network interface(include wireless) via `nmcli` & `nmtui`
  networking.networkmanager.enable = true;

  # BCM4378/brcmfmac: disable Wi-Fi power saving. Powersave is a common source
  # of intermittent association failures / authentication timeouts, which NM
  # mistakes for a bad key, re-prompts, and lets the client (Noctalia, nmtui,
  # nmcli) save as a duplicate "<SSID> 1" profile. See WORKAROUNDS.md WA-024/025.
  networking.networkmanager.wifi.powersave = false;

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
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    # 'Docked' means: more than one display is connected or the system is inserted in a docking station
    HandleLidSwitchDocked = "ignore";

    HandlePowerKey = "suspend";
    HandlePowerKeyLongPress = "poweroff";
  };
  systemd.targets.sleep.enable = true;
  systemd.sleep.settings.Sleep = {
    AllowSuspend = "yes";
    AllowHibernate = "no";
    AllowSuspendThenHibernate = "no";
    HibernateDelaySec = "5min";
  };

  # Cap charging at 90%: the SMC's charge_control_end_threshold does not reliably survive a reboot,
  # and a udev rule that writes it races the driver probe, so re-apply it from a boot-time service.
  # TLP would set it too but conflicts with tuned (modules/nixos/desktop/power.nix); the driver
  # derives charge_control_start_threshold as end - 5 and ignores writes to it.
  systemd.services.apple-charge-limit = {
    description = "Cap the battery charge at 90%";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      path = [ pkgs.coreutils ];
      ExecStart = pkgs.writeShellScript "apple-charge-limit" ''
        limit=90 # percent
        node=/sys/class/power_supply/macsmc-battery/charge_control_end_threshold
        # macsmc probes asynchronously, so retry briefly instead of racing the driver.
        for _ in $(seq 1 30); do
          if [ -e "$node" ] && echo "$limit" > "$node" 2>/dev/null &&
            [ "$(cat "$node")" = "$limit" ]; then
            echo "battery charge capped at $limit%"
            exit 0
          fi
          sleep 1
        done
        echo "battery charge cap: $(cat "$node" 2>/dev/null || echo "$node missing")" >&2
        exit 1
      '';
    };
  };

  # After adding this snippet, you need to restart the system for the touchbar to work.
  hardware.apple.touchBar = {
    enable = true;
    package = pkgs.tiny-dfr;
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
        {
          Text = "F1";
          Action = "F1";
        }
        {
          Text = "F2";
          Action = "F2";
        }
        {
          Text = "F12";
          Action = "F12";
        }
      ];
    };
  };

}
