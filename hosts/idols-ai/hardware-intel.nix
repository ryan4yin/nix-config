{
  ...
}:
{
  # kvm virtualization support
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "kvm-intel"
    # Provide a connected DRM output when the NVIDIA-attached monitors are off.
    # Niri exposes it as Virtual-1 for headless Sunshine sessions.
    "vkms"
    # Bind the board's NCT6687D SuperIO, otherwise fan RPM and PCH/VRM
    # temperatures are missing.
    "nct6683"
  ];
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
    # Create Virtual-1 as soon as vkms loads, including during normal physical sessions.
    options vkms create_default_dev=1
  '';
  boot.extraModulePackages = [ ];

  # The i5-13600KF has no iGPU; the RTX 4090 and vkms are the DRM devices.
  hardware.enableRedistributableFirmware = true;

  # May help services that have trouble accessing /dev/dri (e.g., jellyfin/plex):
  # users.users.<service>.extraGroups = [ "video" "render" ];
}
