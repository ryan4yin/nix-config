{ ... }:
{
  enabled = true;
  hasBtrPool = true;
  onCalendar = "Tue,Sat *-*-* 3:45:20";
  snapshotDir = "@snapshots";
  sources = [ "@persistent" ];
  snapshotCreate = "always";
  hasTarget = false;
}
