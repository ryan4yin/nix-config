{config, pkgs, ...}:

{
  users.groups = {
    ryan = {};
    docker = {};
    wireshark = {};
  };
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ryan = {
    isNormalUser = true;
    description = "ryan";
    extraGroups = [ "ryan" "users" "networkmanager" "wheel" "docker" "wireshark" "adbusers" ];
    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJx3Sk20pLL1b2PPKZey2oTyioODrErq83xG78YpFBoj"
    ];
  };
}