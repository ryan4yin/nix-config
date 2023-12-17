{pkgs, ...}: {
  ###################################################################################
  #
  #  Visualisation - Libvirt(QEMU/KVM) / Docker / LXD / WayDroid
  #
  ###################################################################################

  boot.kernelModules = ["kvm-amd" "kvm-intel" "vfio-pci"];
  # Enable nested virsualization, required by security containers and nested vm.
  boot.extraModprobeConfig = "options kvm_intel nested=1"; # for intel cpu
  # boot.extraModprobeConfig = "options kvm_amd nested=1";  # for amd cpu

  virtualisation = {
    libvirtd = {
      enable = true;
      # hanging this option to false may cause file permission issues for existing guests.
      # To fix these, manually change ownership of affected files in /var/lib/libvirt/qemu to qemu-libvirtd.
      qemu.runAsRoot = true;
    };
    waydroid.enable = true;
    lxd.enable = true;
  };

  environment.systemPackages = with pkgs; [
    # Need to add [File (in the menu bar) -> Add connection] when start for the first time
    virt-manager

    # QEMU/KVM, provides:
    #   qemu-storage-daemon qemu-edid qemu-ga
    #   qemu-pr-helper qemu-nbd elf2dmp qemu-img qemu-io
    #   qemu-kvm qemu-system-x86_64 qemu-system-aarch64 qemu-system-i386
    qemu_kvm

    # Install all packages about QEMU, provides:
    #   ......
    #   qemu-loongarch64 qemu-system-loongarch64
    #   qemu-riscv64 qemu-system-riscv64 qemu-riscv32  qemu-system-riscv32
    #   qemu-system-arm qemu-arm qemu-armeb qemu-system-aarch64 qemu-aarch64 qemu-aarch64_be
    #   qemu-system-xtensa qemu-xtensa qemu-system-xtensaeb qemu-xtensaeb
    #   ......
    qemu_full
  ];
}
