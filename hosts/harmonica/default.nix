# My MacBook Pro - Computer for Business
{ pkgs, ... } @ args:

{
  imports = [
    ../../modules/darwin/common.nix    
  ];

  # # enable flakes globally
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # Use this instead of services.nix-daemon.enable if you
  # don't wan't the daemon service to be managed for you.
  # nix.useDaemon = true;

  nix.package = pkgs.nix;

  programs.nix-index.enable = true;

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  # Set your time zone.
  time.timeZone = "Asia/Shanghai";
}


