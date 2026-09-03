{
  myvars,
  lib,
  outputs,
}:
let
  username = myvars.username;
  hosts = [
    "shoukei-niri"
  ];
in
lib.genAttrs hosts (
  name:
  let
    hm = outputs.nixosConfigurations.${name}.config.home-manager.users.${username};
    hypridleConfig = builtins.readFile hm.xdg.configFile."hypr/hypridle.conf".source;
    hasHypridleLines = lines: lib.hasInfix (lib.concatStringsSep "\n" lines) hypridleConfig;
  in
  {
    homeDirectory = hm.home.homeDirectory;
    hypridleScreenOffIgnoresInhibitors = hasHypridleLines [
      "    timeout = 360                                      # 6 minutes"
      "    ignore_inhibit = true"
    ];
    hypridleScreenOffSkipsPlayingMedia = hasHypridleLines [
      "    condition_cmd = ! playerctl -a status 2>/dev/null | grep -q '^Playing$'"
      "    condition_retry = 30"
    ];
    hypridleLockIgnoresInhibitors = hasHypridleLines [
      "    timeout = 1200                                     # 20 minutes"
      "    ignore_inhibit = true"
    ];
  }
)
