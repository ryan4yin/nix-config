# Flake Outputs

## Is such a complex and fine-grained structure necessary?

There is no need to do this when you have a small number of machines.

But when you have a large number of machines, it is necessary to manage them in a fine-grained way,
otherwise, it will be difficult to manage and maintain them.

I have more than a dozen machines now, and a fine-grained layout keeps them manageable.

## Tests

Simple configurations do not need tests, but a dozen machines make a broken setting easy to miss.

There are two types of tests: eval tests and NixOS tests. They catch configuration errors before a
change reaches a real machine.

Related projects & docs:

- [haumea](https://github.com/nix-community/haumea): Filesystem-based module system for Nix
- [Unveiling the Power of the NixOS Integration Test Driver (Part 1)](https://nixcademy.com/2023/10/24/nixos-integration-tests/)
- [NixOS Tests - NixOS Manual](https://nixos.org/manual/nixos/stable/#sec-nixos-tests)

### 1. Eval Tests

Eval Tests evaluate the expressions and compare the results with the expected results. It runs fast,
but it doesn't build a real machine. We use eval tests to ensure that some attributes are correctly
set for each NixOS and nix-darwin host.

How to run all the eval tests:

```bash
just test
```

`just test` exits non-zero unless the suite returns `true`. The underlying
`nix eval .#evalTests --show-trace --print-build-logs --verbose` prints the result but exits 0 even
on `false`, so read its output when you need the failing trace.

Each test is a directory `outputs/<system>/tests/<name>/` holding `expr.nix` and `expected.nix`; the
suite passes when every `expr` equals its `expected`.

#### Which tests cover a new host

Some tests iterate over every configuration, so a new host is covered automatically and must satisfy
them. Others name specific hosts and only cover a new host if you add it.

| Kind                | Tests                                                                                                                                                                                                      |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Every configuration | `hostname`, `kernel`, `nix-system-features`, `security-apparmor`, `security-container-groups`, `security-exporters`, `security-firewall`, `security-k3s-kubeconfig`, `security-kernel`, `security-ssh-x11` |
| Named hosts only    | `btrbk`, `home-manager`, `home-manager-xdg`, `computer-use-headless`, `k3s-api-endpoint`, `k3s-master-home-manager`, `idols-ai-gpu`, `youko-metrics`, `ups-metrics`, `shoukei-logind`                      |

`hostname` expects each configuration's `networking.hostName` to equal its name. Niri desktop
configurations are the exception (`ai-niri` → `ai`, `shoukei-niri` → `shoukei`) and are listed in
`specialExpected` in that platform's `hostname/expected.nix`.

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

How to run a host's NixOS tests:

```bash
# Format: nix build .#<name>-nixos-tests

nix build .#ruby-nixos-tests
```

Only `ruby` currently defines a `*-nixos-tests` output.

## Overview

All the outputs of this flake are defined here.

```bash
› tree
.
├── default.nix       # The entry point, all the outputs are composed here.
├── README.md
├── aarch64-darwin    # All outputs for macOS Apple Silicon
│   ├── default.nix
│   ├── src           # every host has its own file in this directory
│   │   ├── fern.nix
│   │   └── frieren.nix
│   └── tests         # eval tests
├── aarch64-linux     # All outputs for Linux ARM64
│   ├── default.nix
│   ├── src           # every host has its own file in this directory
│   │   ├── 12kingdoms-shoukei.nix
│   │   └── idols-akane.nix
│   └── tests         # eval tests
└── x86_64-linux      # All outputs for Linux x86_64
    ├── default.nix
    ├── nixos-tests
    ├── src           # every host has its own file in this directory
    │   ├── 12kingdoms-shoryu.nix
    │   ├── 12kingdoms-shushou.nix
    │   ├── 12kingdoms-youko.nix
    │   ├── idols-ai.nix
    │   ├── idols-kana.nix
    │   ├── idols-ruby.nix
    │   ├── k3s-test-1-master-1.nix
    │   ├── k3s-test-1-master-2.nix
    │   ├── k3s-test-1-master-3.nix
    │   ├── k3s-test-1-worker-1.nix
    │   ├── k3s-test-1-worker-2.nix
    │   └── k3s-test-1-worker-3.nix
    └── tests         # eval tests (btrbk, computer-use-headless, hostname,
                      # kernel, security-*, ups-metrics, ...)
```

The tree lists the per-host sources and tests. The flake also exposes a `checks` output: every
system has `eval-tests` and `pre-commit-check`, and `x86_64-linux` adds `security-exporters`, which
imports the top-level `tests/security-exporters.nix`. See [`../SECURITY.md`](../SECURITY.md) for
when to run it.
