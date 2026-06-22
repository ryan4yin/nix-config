{
  lib,
  outputs,
}:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (_: {
  autoAllocateUids = true;
  hasUidRange = true;
  hasAutoAllocateUidsFeature = true;
  hasCgroupsFeature = true;
  hasDevNetSandboxPath = true;
})
