{
  pkgs,
  pkgs-master,
  pkgs-stable,
  pkgs-blender,
  nixpak,
  ...
}:
let
  callArgs = {
    mkNixPak = nixpak.lib.nixpak {
      inherit (pkgs) lib;
      inherit pkgs;
    };
  };
  wrapper = _pkgs: path: (_pkgs.callPackage path callArgs);
in
{
  # FIDO2 hotplug for sandboxed browsers (see modules/fido-bwrap.nix). The
  # directory is created at boot, before udevd starts, so the browser bind
  # succeeds even with no key present. NixOS applies /dev tmpfiles entries only
  # at boot; for a first deploy via switch, see hardening/README.md (Limits).
  # Hard links share the device inode, so logind's uaccess ACLs stay
  # authoritative, and removal on unplug leaves no stale node for a reused
  # hidraw minor. 60-fido-id.rules sets ID_FIDO_TOKEN from the report
  # descriptor, so the CanoKey's keyboard interface is never linked.
  #
  # Game sandboxes (see modules/gaming-policy.nix) get joysticks the same way:
  # their evdev nodes are linked into /dev/gamepad-input, which the sandbox
  # mounts as /dev/input. A device that also claims to be a keyboard is left
  # out, so key events never reach a game.
  systemd.tmpfiles.rules = [
    "d /dev/fido-hidraw 0755 root root -"
    "d /dev/gamepad-input 0755 root root -"
  ];
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="hidraw", ENV{ID_FIDO_TOKEN}=="1", RUN+="${pkgs.coreutils}/bin/ln -f /dev/%k /dev/fido-hidraw/%k"
    ACTION=="remove", SUBSYSTEM=="hidraw", RUN+="${pkgs.coreutils}/bin/rm -f /dev/fido-hidraw/%k"
    ACTION=="add", SUBSYSTEM=="input", KERNEL=="event*|js*", ENV{ID_INPUT_JOYSTICK}=="1", ENV{ID_INPUT_KEYBOARD}!="1", RUN+="${pkgs.coreutils}/bin/ln -f $devnode /dev/gamepad-input/%k"
    ACTION=="remove", SUBSYSTEM=="input", KERNEL=="event*|js*", RUN+="${pkgs.coreutils}/bin/rm -f /dev/gamepad-input/%k"
  '';

  # Add nixpaked Apps into nixpkgs, and reference them in home-manager or other nixos modules
  nixpkgs.overlays = [
    (_: super: {
      nixpaks = {
        qq = wrapper pkgs-master ./qq.nix;
        telegram-desktop = wrapper super ./telegram-desktop.nix;
        firefox = wrapper super ./firefox.nix;
        google-chrome = wrapper super ./google-chrome.nix;
        chromium = wrapper super ./chromium.nix;
        brave-origin = wrapper super ./brave-origin.nix;
        microsoft-edge = wrapper super ./microsoft-edge.nix;
        foliate = wrapper super ./foliate.nix;
        krita = wrapper pkgs-stable ./krita.nix;
        bambu-studio = wrapper pkgs-master ./bambu-studio.nix;
        orca-slicer = wrapper pkgs-master ./orca-slicer.nix;
        zoom = wrapper super ./zoom.nix;
        remmina = wrapper super ./remmina.nix;
        obs-studio = wrapper super ./obs-studio.nix;
        blender = wrapper pkgs-blender ./blender.nix;
        musescore = wrapper pkgs-stable ./musescore.nix;
        mpv = wrapper super ./mpv.nix;
        imv = wrapper super ./imv.nix;
        wechat = wrapper pkgs-master ./wechat.nix;
        umu = wrapper super ./umu.nix;
        steam = wrapper super ./steam.nix;
        heroic = wrapper super ./heroic.nix;
      };
    })
  ];
}
