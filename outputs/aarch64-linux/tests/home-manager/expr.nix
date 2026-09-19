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
    listeners = hm.services.hypridle.settings.listener;
    findByAction = action: lib.findFirst (l: (l."on-timeout" or "") == action) { } listeners;
    screenOff = findByAction "niri msg action power-off-monitors";
    lock = findByAction "noctalia msg session lock";
  in
  {
    homeDirectory = hm.home.homeDirectory;
    hypridleScreenOffIgnoresInhibitors = screenOff.ignore_inhibit or false;
    hypridleScreenOffSkipsPlayingMedia = (screenOff.condition_cmd or "") != "";
    hypridleLockIgnoresInhibitors = lock.ignore_inhibit or false;
  }
)
