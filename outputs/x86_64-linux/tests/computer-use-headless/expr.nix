{
  myvars,
  lib,
  outputs,
}:
let
  username = myvars.username;
  hosts = [
    "ruby"
    "kana"
  ];
in
lib.genAttrs hosts (
  name:
  let
    system = outputs.nixosConfigurations.${name}.config;
    home = system.home-manager.users.${username};
  in
  {
    computerUse = system.modules.desktop.computerUse.enable;
    atspi = system.services.gnome.at-spi2-core.enable;
    clashVerge = system.programs.clash-verge.enable;
    timeZone = system.time.timeZone;
    xvfbRestart = home.systemd.user.services.xvfb.Service.Restart;
    i3Restart = home.systemd.user.services.i3.Service.Restart;
    vnc = home.modules.desktop.computerUse.vnc;
    cuaDriver = home.modules.desktop.computerUse.cuaDriver;
    brave = home.programs.brave-origin.enable;
    chromium = home.programs.chromium.enable;
  }
)
