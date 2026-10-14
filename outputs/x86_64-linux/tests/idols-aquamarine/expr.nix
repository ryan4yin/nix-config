{
  myvars,
  outputs,
  lib,
  ...
}:
let
  eval = outputs.nixosConfigurations.aquamarine;
  cfg = eval.config;
  inherit (myvars.networking.hostsAddr.aquamarine) ipv4;
in
{
  # A server configuration is named after the bare hostname (no `-niri`).
  hostNameIsBare = cfg.networking.hostName == "aquamarine";

  # The two Radeon AI PRO R9700 cards: driver and the IOMMU mode ROCm needs for multi-GPU.
  amdgpuDriverLoaded = builtins.elem "amdgpu" cfg.boot.kernelModules;
  iommuPassthrough = builtins.elem "iommu=pt" cfg.boot.kernelParams;
  # This board's ACPI firmware cannot power the dGPU back on, and amdgpu throws
  # the error away, so the card dies on its first idle resume (./ROCM.md, WA-032).
  runtimePmDisabled = builtins.elem "amdgpu.runpm=0" cfg.boot.kernelParams;

  # An unattended host recovers a hung card itself instead of waiting for a reboot.
  gpuRecoveryEnabled = builtins.elem "amdgpu.gpu_recovery=1" cfg.boot.kernelParams;
  aspmDisabled = builtins.elem "pcie_aspm=off" cfg.boot.kernelParams;
  cStatesCapped = builtins.elem "processor.max_cstate=2" cfg.boot.kernelParams;

  # suzi's fake-ip DNS returns AAAA records with no working IPv6 path, so the
  # generated gai.conf has to sort IPv4 first (see ./default.nix).
  prefersIpv4 = lib.hasInfix "precedence ::ffff:0:0/96 100" cfg.environment.etc."gai.conf".text;

  # The Strata checkout lives under ~/src, which has to survive the tmpfs root
  # like ~/codes does.
  sourceCheckoutsPersistent = builtins.any (
    d: d.directory == "/home/${myvars.username}/src"
  ) cfg.preservation.preserveAt."/persistent".users.${myvars.username}.directories;
  rootlessPodmanEnabled = cfg.virtualisation.podman.enable;

  # A server tracks the nixpkgs default (stable/LTS) kernel, not `-latest`.
  stableKernel = cfg.boot.kernelPackages.kernel.version == eval.pkgs.linuxPackages.kernel.version;
  btopShowsRadeon = cfg.modules.btop.package == eval.pkgs.btop-rocm;
  # CAP_PERFMON inside the wrapper is what the i915 iGPU needs.
  btopReadsIgpu = cfg.modules.btop.perfmon;
  gpuMetricsExported = builtins.elem "drm" cfg.services.prometheus.exporters.node.enabledCollectors;
  # node_exporter rejects a repeated flag, and this list merges with the base
  # module's entries, so a duplicate restart-loops the unit.
  collectorFlagsUnique =
    builtins.length (cfg.services.prometheus.exporters.node.enabledCollectors)
    == builtins.length (lib.unique cfg.services.prometheus.exporters.node.enabledCollectors);
  inferenceUserCanRender = builtins.elem "render" cfg.users.users.${myvars.username}.extraGroups;

  # Headless: no desktop session, no Home Manager.
  noHomeManager = !cfg ? home-manager.users;

  # The board renames the wired NIC with the PCIe topology, so networkd matches the
  # `en*` prefix; a name-based match leaves the host without an address.
  staticAddressMatchesWiredInterface =
    builtins.elem "${ipv4}/24" cfg.systemd.network.networks."10-lan".networkConfig.Address
    && cfg.systemd.network.networks."10-lan".matchConfig.Name == [ "en*" ];

  # Ephemeral root with the persistent volume required at boot, as on `ai`.
  rootIsTmpfs = cfg.fileSystems."/".fsType or null == "tmpfs";
  stateIsPersistent = cfg.fileSystems."/persistent".neededForBoot or false;

  # Install step 4 of ./README.md depends on this mapper name staying put.
  luksMapperNamed = builtins.attrNames cfg.boot.initrd.luks.devices == [ "aqua-luks" ];
}
