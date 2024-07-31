{pkgs, ...}: let
  configDir = "/var/lib/homepage-dashboard";
in {
  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/misc/homepage-dashboard.nix
  services.homepage-dashboard = {
    enable = true;
    listenPort = 4401;
    openFirewall = false;
  };
  systemd.services.homepage-dashboard.environment = {
    HOMEPAGE_CONFIG_DIR = configDir;

    # 1. The value of env var HOMEPAGE_VAR_XXX will replace {{HOMEPAGE_VAR_XXX}} in any config
    # HOMEPAGE_VAR_XXX_APIKEY = "myapikey";
    # 2. The value of env var HOMEPAGE_FILE_XXX must be a file path,
    # the contents of which will be used to replace {{HOMEPAGE_FILE_XXX}} in any config
  };
  # Install the homepage-dashboard configuration files
  system.activationScripts.installHomepageDashboardConfig = ''
    mkdir -p ${configDir}
    ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F600 ${./config}/ ${configDir}/

    ${pkgs.systemdMinimal}/bin/systemctl restart homepage-dashboard
  '';
}
