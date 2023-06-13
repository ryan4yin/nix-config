# all the configuration options are documented here:
#    https://daiderd.com/nix-darwin/manual/index.html#sec-options
{ pkgs, lib, ... }:
{
  # # enable flakes globally
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

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

  # Apps
  # `home-manager` currently has issues adding them to `~/Applications`
  # Issue: https://github.com/nix-community/home-manager/issues/1341
  environment.systemPackages = with pkgs; [
    neovim
    git
    nushell  # my custom shell
  ];

  environment.variables.EDITOR = "nvim";

  # Fonts
  fonts = {
    # use fonts specified by user rather than default ones
    fontDir.enable = true;

    fonts = with pkgs; [
      # icon fonts
      material-design-icons
      font-awesome

      # nerdfonts
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "JetBrainsMono"
          "Iosevka"
        ];
      })

    ];
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.admin = {
    home = "/Users/admin";
    description = "admin";

    # set user's default shell to nushell
    # this may not work, to change the default shell manually, use
    #    `chsh -s /run/current-system/sw/bin/nu`
    shell = pkgs.nushell;
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = true;
  environment.shells = [
    pkgs.zsh
    pkgs.nushell  # my custom shell
  ];
}
