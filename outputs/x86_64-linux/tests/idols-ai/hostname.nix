{
  myvars,
  outputs,
}: let
  hostname = "ai";
  username = myvars.username;

  getHostName = nixosName:
    outputs.nixosConfigurations.${nixosName}.config.home-manager.users.${username}.home.homeDirectory;
in {
  tests."hostname-${hostname}-hyprland" = {
    expr = getHostName "${hostname}-hyprland";
    expected = hostname;
  };

  tests."hostname-${hostname}-i3" = {
    expr = getHostName "${hostname}-i3";
    expected = hostname;
  };
}
