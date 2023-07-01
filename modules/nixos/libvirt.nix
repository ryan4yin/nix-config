
{ lib, pkgs, ... }:

{
  ###################################################################################
  #
  #  Enable Libvirt(QEMU/KVM)
  #
  ###################################################################################

  virtualisation = {
    libvirtd = {
      enable = true;
      # hanging this option to false may cause file permission issues for existing guests. 
      # To fix these, manually change ownership of affected files in /var/lib/libvirt/qemu to qemu-libvirtd.
      qemu.runAsRoot = true;
    };

    qemu = {
      # default to QEMU/KVM
      package = pkgs.qemu_kvm;
    };
  };
  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [ virt-manager ];

  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];
  # Enable nested virsualization, required by security containers and nested vm.
  boot.extraModprobeConfig = "options kvm_intel nested=1";  # for intel cpu
  # boot.extraModprobeConfig = "options kvm_amd nested=1";  # for amd cpu


  # NixOS VM should enable this:
  # services.qemuGuest = {
  #   enable = true;
  #   package = pkgs.qemu_kvm.ga;
  # };
}
