# Idols - Ruby

NixOS VM running under libvirt on `shoryu`, used to run AI agents. It owns the shared agent and
computer-use modules (`packages.nix`, `computer-use.nix`, `oci-containers/`) that
[`idols-kana`](../idols-kana/) imports, and is the only host with a `*-nixos-tests` output.

- Deploy from the VM with `just local`.
- Host inventory and role context: [`../README.md`](../README.md).
