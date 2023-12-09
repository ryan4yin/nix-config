{ username, ... } @ args:
#############################################################
#
#  Harmonica - my MacBook Pro 2020 13-inch, mainly for business.
#
#############################################################
let
  hostname = "harmonica";
in {
  imports = [
    ../../modules/darwin

    ../../secrets/darwin.nix
  ];

  nixpkgs.overlays = import ../../overlays args;

  networking.hostName = hostname;
  networking.computerName = hostname;
  system.defaults.smb.NetBIOSName = hostname;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    home = "/Users/${username}";
    description = username;

    # set user's default shell back to zsh
    #    `chsh -s /bin/zsh`
    # DO NOT change the system's default shell to nushell! it will break some apps!
    # It's better to change only starship/alacritty/vscode's shell to nushell!
  };
}
