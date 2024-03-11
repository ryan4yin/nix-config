# Flake Outputs

## Is such a complex and fine-grained structure necessary?

There is no need to do this when you have a small number of machines.

But when you have a large number of machines, it is necessary to manage them in a fine-grained way,
otherwise, it will be difficult to manage and maintain them.

## Overview

All the outputs of this flake are defined here.

```bash
› tree
.
├── default.nix       # The entry point, all the outputs are composed here.
├── README.md
├── aarch64-darwin    # All outputs for macOS Apple Silicon
│   ├── default.nix   # The entry point for all outputs for macOS Apple Silicon
│   └── src
│       └── fern.nix
├── aarch64-linux     # All outputs for Linux ARM64
│   ├── default.nix
│   └── src
│       ├── 12kingdoms-rakushun.nix
│       └── 12kingdoms-suzu.nix
├── riscv64-linux    # All outputs for Linux RISCV64
│   ├── default.nix
│   └── src
│       ├── rolling-girls-nozomi.nix
│       └── rolling-girls-yukina.nix
├── x86_64-darwin   # All outputs for macOS Intel
│   ├── default.nix
│   └── src
│       └── harnomica.nix
└── x86_64-linux    # All outputs for Linux x86_64
    ├── default.nix
    ├── src
    │   ├── 12kindoms-shoukei.nix
    │   ├── homelab-tailscale-gw.nix
    │   ├── idols-ai.nix
    │   ├── idols-aquamarine.nix
    │   ├── idols-kana.nix
    │   ├── idols-ruby.nix
    │   ├── k3s-prod-1-master-1.nix
    │   ├── k3s-prod-1-master-2.nix
    │   ├── k3s-prod-1-master-3.nix
    │   ├── k3s-prod-1-worker-1.nix
    │   ├── k3s-prod-1-worker-2.nix
    │   ├── k3s-prod-1-worker-3.nix
    │   ├── kubevirt-shoryu.nix
    │   ├── kubevirt-shushou.nix
    │   └── kubevirt-youko.nix
    └── tests

12 directories, 28 files
```


