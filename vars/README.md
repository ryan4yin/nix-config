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

### 2. `networking.nix`

Comprehensive network configuration including:

- **Gateway settings**: Main router and proxy gateway configurations
- **DNS servers**: IPv4 and IPv6 name servers
- **Host inventory**: Complete mapping of all hosts with their network interfaces and IP addresses
- **SSH configuration**: Remote builder aliases and known hosts configuration
- **Network topology**: Physical machines, VMs, Kubernetes clusters, and SBCs

## Host Categories

The networking configuration covers:

- **Physical machines**: Desktop PCs, Apple Silicon systems, SBCs
- **Virtual machines**: KubeVirt guests, K3s nodes
- **Kubernetes clusters**: Production and testing environments
- **Network infrastructure**: Routers, gateways, and DNS configuration

## Usage

These variables are imported and used throughout the configuration to ensure consistency across all
hosts and maintain centralized network and security settings.
