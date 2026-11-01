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
  serverRaplEnabled = lib.genAttrs [ "aquamarine" "shoryu" "shushou" "youko" ] (_: true);
  serverRaplReaderOnly = true;
  desktopRaplDisabled = true;
  guestsHaveNoRapl = true;
  desktopBatteryReporting = true;
}
