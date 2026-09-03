{ outputs, ... }:
let
  login = outputs.nixosConfigurations.shoukei-niri.config.services.logind.settings.Login;
in
{
  lidSwitch = login.HandleLidSwitch or null;
  lidSwitchExternalPower = login.HandleLidSwitchExternalPower or null;
  lidSwitchDocked = login.HandleLidSwitchDocked or null;
  powerKey = login.HandlePowerKey or null;
  powerKeyLongPress = login.HandlePowerKeyLongPress or null;

  oldLowercaseKeysAbsent =
    !(login ? lidSwitch)
    && !(login ? lidSwitchExternalPower)
    && !(login ? lidSwitchDocked)
    && !(login ? powerKey)
    && !(login ? powerKeyLongPress);
}
