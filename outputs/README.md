# Flake Outputs

## Is such a complex and fine-grained structure necessary?

There is no need to do this when you have a small number of machines.

But when you have a large number of machines, it is necessary to manage them in a fine-grained way,
otherwise, it will be difficult to manage and maintain them.

The number of my machines has grown to more than 20, and the increase in scale has shown signs of
getting out of control of complexity, so it is a natural and reasonable choice to use this
fine-grained architecture to manage.

## Tests

Testing is not necessary when your configuration is not complex, but with the increase in the number
and configuration of your machines, testing becomes more and more important.

We have two types of tests: eval tests and nixos tests, both of which can help us detect many
obscure errors early, so as to avoid testing directly in the real world, and to avoid failures in
personal computers and even corporate online environments.

Related projects & docs:

- [haumea](https://github.com/nix-community/haumea): Filesystem-based module system for Nix
- [Unveiling the Power of the NixOS Integration Test Driver (Part 1)](https://nixcademy.com/2023/10/24/nixos-integration-tests/)
- [NixOS Tests - NixOS Manual](https://nixos.org/manual/nixos/stable/#sec-nixos-tests)

### 1. Eval Tests

> TODO: More Tests!

Eval Tests evaluate the expressions and compare the results with the expected results. It runs fast,
but it doesn't build a real machine. We use eval tests to ensure that some attributes are correctly
set for each NixOS host(not Darwin).

How to run all the eval tests:

```bash
nix eval .#evalTests --show-trace --print-build-logs --verbose
```

### 2. NixOS Tests

> WIP: not working yet

NixOS Tests builds and starts virtual machines using our NixOS configuration and run tests on them.
Comparing to eval tests, it runs slow, but it builds a real machine, and we can test the whole
system actually works as expected.

Problems:

- [ ] We need a private cache server, so that our NixOS tests do not need to build some custom
      packages every time we run the tests.
- [ ] Cannot test the whole host, because my host relies on its unique ssh host key to decrypt its
      agenix secrets.
  - [ ] Maybe it's better to test every service separately, not the whole host?

How to run NixOS tests for every host:

```bash
# Format: nix build .#<name>-nixos-tests

nix build .#ruby-nixos-tests
```

## Overview

All the outputs of this flake are defined here.

```bash
› tree
.
├── default.nix       # The entry point, all the outputs are composed here.
├── README.md
├── aarch64-darwin    # All outputs for macOS Apple Silicon
│   ├── default.nix
│   └── src           # every host has its own file in this directory
│       └── fern.nix
├── aarch64-linux     # All outputs for Linux ARM64
│   ├── default.nix
│   ├── src           # every host has its own file in this directory
│   │   ├── 12kingdoms-rakushun.nix
│   │   └── 12kingdoms-suzu.nix
│   └── tests         # eval tests
│       └── hostname
│           ├── expected.nix
│           └── expr.nix
├── riscv64-linux     # All outputs for Linux RISCV64
│   ├── default.nix
│   ├── src           # every host has its own file in this directory
│   │   ├── rolling-girls-nozomi.nix
│   │   └── rolling-girls-yukina.nix
│   └── tests         # eval tests
│       └── hostname
│           ├── expected.nix
│           └── expr.nix
├── x86_64-darwin     # All outputs for macOS Intel
│   ├── default.nix
│   └── src
│       └── harnomica.nix
└── x86_64-linux      # All outputs for Linux x86_64
    ├── default.nix
    ├── nixos-tests
    ├── src           # every host has its own file in this directory
    │   ├── 12kingdoms-shoukei.nix
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
    └── tests         # eval tests
        ├── home-manager
        │   ├── expected.nix
        │   └── expr.nix
        └── hostname
            ├── expected.nix
            └── expr.nix

```
