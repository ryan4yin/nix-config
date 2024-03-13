{
  myvars,
  outputs,
}: let
  hostname = "ai";
  username = myvars.username;

  getHomeDirectory = nixosName:
    outputs.nixosConfigurations.${nixosName}.config.home-manager.users.${username}.home.homeDirectory;
in {
  tests."home-manager-${hostname}-hyprland" = {
    expr = getHomeDirectory "${hostname}-hyprland";
    expected = "/home/${username}";
  };

  tests."hostname-${hostname}-i3" = {
    expr = getHomeDirectory "${hostname}-i3";
    expected = "/home/${username}";
  };
}
