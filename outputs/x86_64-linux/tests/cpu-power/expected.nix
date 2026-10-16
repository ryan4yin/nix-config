{
  lib,
  ...
}:
{
  governors = lib.genAttrs [ "ai-niri" "aquamarine" "shoryu" "shushou" "youko" ] (_: "powersave");
  noTuned = true;
  noEeeWorkaround = true;
  noFrequencyCaps = true;
  guestsHaveNoCpuPolicy = true;
  desktopBatteryReporting = true;
}
