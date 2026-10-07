# Host - Shoukei

This is NixOS's configuration for my Macbook Pro 2022 M2, 16G RAM.

This laptop joins untrusted networks and uses DHCP instead of a static IP, so it has no entry in
`vars/networking.nix`.

## x86/x86_64 applications

The M2 uses 16 KiB pages, and FEX does not emulate 4 KiB guest pages, so x86/x86_64 binaries cannot
run directly on this kernel. [`game/`](./game/default.nix) enables `programs.x86-on-arm` from
[our fork](https://github.com/ryan4yin/nix-x86-on-aarch64) of
[rowanG077/nix-x86-on-aarch64](https://github.com/rowanG077/nix-x86-on-aarch64), which runs FEX
inside a 4 KiB `muvm` microVM and registers both ELF handlers:

- run an x86/x86_64 ELF directly, or use `x86-arm run <program>`;
- `nix-shell -p x86pkgs.hello --run hello` for the x86 package set;
- `steam` and `x86-arm-wine` for games and Windows programs.

The microVM is capped at 6 GiB (`memoryMiB`) on this 16 GiB machine, and needs `/dev/kvm` plus a
running systemd user session. See [WORKAROUNDS.md](../../WORKAROUNDS.md) WA-021.

Because the host no longer registers qemu-user binfmt, `podman run --platform=linux/amd64`, x86
chroots, and local builds of uncached x86 derivations need a remote x86_64 builder (see
[WORKAROUNDS.md](../../WORKAROUNDS.md) WA-022).

Related:

- [M2 Series Feature Support - Asahi Linux](https://asahilinux.org/docs/platform/feature-support/m2/)
- [nixos-installer/README.shoukei.md](../../nixos-installer/README.shoukei.md)
- [nixos-apple-silicon - UEFI Boot Standalone NixOS](https://github.com/nix-community/nixos-apple-silicon/blob/main/docs/uefi-standalone.md)
