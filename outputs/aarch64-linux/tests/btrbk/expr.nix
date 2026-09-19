{ outputs, ... }:
let
  cfg = outputs.nixosConfigurations.shoukei-niri.config;
  instance = cfg.services.btrbk.instances.btrbk;
  volume = instance.settings.volume."/btr_pool";
in
{
  enabled = cfg.modules.btrbk.enable;
  hasBtrPool = cfg.fileSystems ? "/btr_pool";
  onCalendar = instance.onCalendar;
  snapshotDir = volume.snapshot_dir;
  sources = builtins.attrNames volume.subvolume;
  snapshotCreate = volume.subvolume."@persistent".snapshot_create;
  hasTarget = volume ? target;
}
