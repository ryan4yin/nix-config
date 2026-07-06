{
  lib,
  outputs,
}:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (
  name:
  let
    settings = outputs.nixosConfigurations.${name}.config.nix.settings;
    effectiveSystemFeatures =
      (settings.system-features or [ ]) ++ (settings.extra-system-features or [ ]);
  in
  {
    autoAllocateUids = settings.auto-allocate-uids or false;
    hasUidRange = builtins.elem "uid-range" effectiveSystemFeatures;
    hasAutoAllocateUidsFeature = builtins.elem "auto-allocate-uids" (
      settings.experimental-features or [ ]
    );
    hasCgroupsFeature = builtins.elem "cgroups" (settings.experimental-features or [ ]);
    hasNoExplicitSandboxPaths = !(settings ? sandbox-paths);
    hasDevNetExtraSandboxPath = builtins.elem "/dev/net" (settings.extra-sandbox-paths or [ ]);
  }
)
