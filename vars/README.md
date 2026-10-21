# Variables

Common variables and configuration used across my NixOS and nix-darwin configurations.

## Current Structure

```
vars/
├── README.md
├── default.nix         # Main variables entry point
└── networking.nix      # Network configuration and host definitions
```

## Components

### 1. `default.nix`

Contains user information, SSH keys, and password configuration:

- User credentials (username, full name, email)
- Initial hashed password for new installations
- SSH authorized keys (main and backup sets)
- Public key references for system access
- Remote-builder client host keys (`remoteBuilderClientKeys`) that may build through aquamarine

### 2. `networking.nix`

Defines:

- **Gateway settings**: Main router and proxy gateway configurations
- **Home LAN** (`lanCidr`): the trusted LAN prefix the shared host firewall trusts by source
- **Cluster addressing**: `clusterULA6`, the IPv6 ULA prefix for MicroVM guest addresses, and
  `k8sVip`, each k3s cluster's kube-vip API and LoadBalancer VIP block
- **DNS servers**: IPv4 and IPv6 name servers
- **Host inventory**: static LAN hosts and their interfaces; DHCP/mobile hosts (such as the macOS
  hosts) are omitted by design. `homeOnly = true` marks an address that exists only at home; SSH
  aliases and monitoring skip it
- **SSH configuration**: Host aliases and known hosts configuration
- **Network topology**: Physical machines, VMs, Kubernetes clusters, and SBCs

## Host Categories

`networking.nix` maps each host to its LAN address and interface. The authoritative inventory is
[`../hosts/README.md`](../hosts/README.md); this file holds only the addresses.

## Usage

These variables are imported and used throughout the configuration.
