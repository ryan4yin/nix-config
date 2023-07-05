
{ pkgs, lib, ... }:
{
  ###################################################################################
  #
  #  Core configuration for nix-darwin
  #
  #  All the configuration options are documented here:
  #    https://daiderd.com/nix-darwin/manual/index.html#sec-options
  #
  ###################################################################################

  # # enable flakes globally
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  nix.settings.trusted-users = ["admin"];

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

    # set user's default shell back to zsh
    #    `chsh -s /bin/zsh`
    # DO NOT change the system's default shell to nushell! it will break some apps!
    # It's better to change only starship/alacritty/vscode's shell to nushell!
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = true;
  environment.shells = [
    pkgs.zsh
    pkgs.nushell  # my custom shell
  ];
}
