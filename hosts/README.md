# Hosts

This directory contains all host-specific configurations for my NixOS and macOS systems.

## Current Host Inventory

### Physical Machines

#### `idols` - Main Workstations

Named after characters from "Oshi no Ko":

| Host         | Platform    | Hardware              | Purpose               | Status      |
| ------------ | ----------- | --------------------- | --------------------- | ----------- |
| `ai`         | NixOS       | i5-13600KF + RTX 4090 | Gaming & Daily Use    | ✅ Active   |
| `aquamarine` | KubeVirt VM | Virtual               | Monitoring & Services | ✅ Active   |
| `kana`       | NixOS       | Virtual               | Reserved              | ⚪ Not Used |
| `ruby`       | NixOS       | Virtual               | Reserved              | ⚪ Not Used |

#### `darwin` - macOS Systems

Named after characters from "Frieren: Beyond Journey's End":

| Host      | Platform | Hardware                   | Purpose      | Status    |
| --------- | -------- | -------------------------- | ------------ | --------- |
| `fern`    | macOS    | MacBook Pro M2 13" 16GB    | Personal Use | ✅ Active |
| `frieren` | macOS    | MacBook Pro M4Pro 14" 48GB | Work Use     | ✅ Active |

#### `12kingdoms` - Homelab Servers & Apple Silicon Linux

Named after "Twelve Kingdoms":

| Host      | Platform | Hardware                               | Purpose                    | Status    |
| --------- | -------- | -------------------------------------- | -------------------------- | --------- |
| `shoukei` | NixOS    | MacBook Pro M2                         | NixOS on Apple Silicon     | ✅ Active |
| `shoryu`  | NixOS    | MoreFine S500Plus (AMD Ryzen 9 5900HX) | KubeVirt Host & K3s Master | ✅ Active |
| `shushou` | NixOS    | MinisForum UM560 (AMD Ryzen 5 5625U)   | KubeVirt Host & K3s Master | ✅ Active |
| `youko`   | NixOS    | MinisForum HX99G (AMD Ryzen 9 6900HX)  | KubeVirt Host & K3s Master | ✅ Active |

### Virtual Machines & Clusters

#### `k8s` - Kubernetes Infrastructure

- **KubeVirt Cluster**: 3 physical mini PCs (shoryu, shushou, youko) running all VMs
- **K3s Production**: 3 masters + 3 workers for production workloads
- **K3s Testing**: 3 masters for testing and development

#### KubeVirt Host Systems

- **kubevirt-shoryu** - Physical mini PC running KubeVirt/K3s cluster
- **kubevirt-shushou** - Physical mini PC running KubeVirt/K3s cluster
- **kubevirt-youko** - Physical mini PC running KubeVirt/K3s cluster

### External Systems

- **SBCs**: aarch64/riscv64 single-board computers managed in
  [ryan4yin/nixos-config-sbc](https://github.com/ryan4yin/nixos-config-sbc)

## Naming Conventions

- **idols**: Characters from "Oshi no Ko" anime/manga
- **12kingdoms**: Characters from "Twelve Kingdoms" anime/novel series
- **darwin**: Characters from "Frieren: Beyond Journey's End" anime/manga
- **k8s**: Kubernetes-related systems follow standard naming patterns

## How to Add a New Host

The easiest way to add a new host is to copy and adapt an existing similar configuration. All host
configurations follow similar patterns but are customized for specific hardware and use cases.

### General Process

1. **Identify a similar existing host** from the directory structure above
2. **Copy the entire directory** and rename it for your new host
3. **Adapt the configuration files** for your specific hardware and requirements
4. **Update references** in the flake outputs and networking configuration

### Essential Steps

1. Under `hosts/`
   1. Create a new folder under `hosts/` with the name of the new host.
   2. Create & add the new host's `hardware-configuration.nix` to the new folder, and add the new
      host's `configuration.nix` to `hosts/<name>/default.nix`.
   3. If the new host need to use home-manager, add its custom config into `hosts/<name>/home.nix`.
1. Under `outputs/`
   1. Add a new nix file named `outputs/<system-architecture>/src/<name>.nix`.
   2. Copy the content from one of the existing similar host, and modify it to fit the new host.
      1. Usually, you only need to modify the `name` and `tags` fields.
   3. [Optional] Add a new unit test file under `outputs/<system-architecture>/tests/<name>.nix` to
      test the new host's nix file.
   4. [Optional] Add a new integration test file under
      `outputs/<system-architecture>/integration-tests/<name>.nix` to test whether the new host's
      nix config can be built and deployed correctly.
1. Under `vars/networking.nix`
   1. Add the new host's static IP address.
   1. Skip this step if the new host is not in the local network or is a mobile device.

### File Templates

Use existing hosts as templates. The key files typically include:

- `default.nix` - Main host configuration
- `hardware-configuration.nix` - Auto-generated hardware settings
- Platform-specific files (e.g., `nvidia.nix`, `apple-silicon.nix`, etc.)

### Examples to Reference

- **Desktop systems**: See `idols-ai/` for gaming/workstation setup
- **Server systems**: See `kubevirt-shoryu/` for K8s/KubeVirt hosts
- **macOS systems**: See `darwin-fern/` for macOS configurations
- **Apple Silicon**: See `12kingdoms-shoukei/` for ARM Linux setup

All my riscv64 hosts:

![](/_img/nixos-riscv-cluster.webp)

## Distributed Building

I usually run the build command on `Ai` and nix will distribute the build to other NixOS machines,
which is convenient and fast.

When building some packages for riscv64 or aarch64, I often have no cache available because of
various changes under the hood, so I need to build much more packages than usual, which is one of
the reasons why the cluster was originally built, and another reason is distributed building is
cool!

![](/_img/nix-distributed-building.webp)

![](/_img/nix-distributed-building-log.webp)

## References

[Oshi no Ko 【推しの子】 - Wikipedia](https://en.wikipedia.org/wiki/Oshi_no_Ko):

![](/_img/idols-famaily.webp) ![](/_img/idols-ai.webp)

[The Rolling Girls【ローリング☆ガールズ】 - Wikipedia](https://en.wikipedia.org/wiki/The_Rolling_Girls):

![](/_img/rolling_girls.webp)

[List of Twelve Kingdoms characters](https://en.wikipedia.org/wiki/List_of_Twelve_Kingdoms_characters)

![](/_img/12kingdoms-1.webp) ![](/_img/12kingdoms-Youko-Rakushun.webp)

[List of Frieren characters](https://en.wikipedia.org/wiki/List_of_Frieren_characters)
