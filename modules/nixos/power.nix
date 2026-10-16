{ lib, pkgs, ... }:
{
  # These x86 hosts use active Intel/AMD P-state drivers: powersave permits
  # hardware-managed scaling. Apple Silicon keeps its native schedutil policy;
  # generic cpufreq powersave would instead hold the CPU at its minimum.
  powerManagement.cpuFreqGovernor = lib.mkIf pkgs.stdenv.hostPlatform.isx86 "powersave";
}
