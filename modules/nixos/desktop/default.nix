{ mylib, ... }:
{
  imports = mylib.scanPaths ./. ++ [ ../power.nix ];

  # Power-supply reporting for the desktop shell: the laptop's battery, and
  # peripheral batteries on a desktop. UPower only reports state; unlike TuneD it
  # writes no CPU, network, or disk setting.
  services.upower.enable = true;
}
