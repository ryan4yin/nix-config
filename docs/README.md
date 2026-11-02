# Documentation

Canonical index for this repository. Standalone reference material lives in this directory.
Component runbooks stay next to the code they describe so they remain visible during maintenance;
every human-facing document is linked here.

`README.md` and `AGENTS.md` remain at the repository root because GitHub and coding agents require
those entry points.

## Repository

- [Repository overview](../README.md) — systems, components, deployment and validation quick start.
- [Agent guide](../AGENTS.md) — repository conventions, command hazards and validation rules.
- [NixOS modernization options](nixos-modernization-options.md) — design options and decisions.

## Operations and policy

- [Security](SECURITY.md) — threat model, trust boundaries, implemented controls and audits.
- [Backups](BACKUP.md) — backup layers, password model, retention and restore procedure.
- [Workarounds and known gaps](WORKAROUNDS.md) — pins, temporary workarounds and removal conditions.
- [BIOS settings](bios.md) — firmware settings for the physical hosts.
- [Wake-on-LAN](wake-on-lan.md) — firmware prerequisites, NixOS setup and wake commands.
- [Runtime hardening validation](../hardening/tests/runtime-validation.md).

## Hosts and services

- [Host inventory and deployment notes](../hosts/README.md).
- AI desktop: [host runbook](../hosts/idols-ai/README.md) and [VR notes](../hosts/idols-ai/VR.md).
- Akane: [host runbook](../hosts/idols-akane/README.md).
- Aquamarine: [host runbook](../hosts/idols-aquamarine/README.md),
  [iGPU notes](../hosts/idols-aquamarine/IGPU.md) and
  [ROCm notes](../hosts/idols-aquamarine/ROCM.md).
- Kana: [host runbook](../hosts/idols-kana/README.md).
- Ruby: [host runbook](../hosts/idols-ruby/README.md).
- Shoukei: [host runbook](../hosts/12kingdoms-shoukei/README.md).
- Youko homelab: [services overview](../hosts/12kingdoms-youko/homelab-services/README.md),
  [Immich](../hosts/12kingdoms-youko/homelab-services/immich/README.md),
  [monitoring](../hosts/12kingdoms-youko/homelab-services/monitoring/README.md),
  [alert rules](../hosts/12kingdoms-youko/homelab-services/monitoring/alert_rules/README.md),
  [recording rules](../hosts/12kingdoms-youko/homelab-services/monitoring/recording_rules/README.md)
  and [Grafana dashboards](../hosts/12kingdoms-youko/homelab-services/grafana/dashboards/README.md).
- Kubernetes cluster: [k8s host notes](../hosts/k8s/README.md) and
  [disko configuration](../hosts/k8s/disko-config/README.md).
- Infrastructure: [infra overview](../infra/README.md), [RustFS](../infra/rustfs/README.md),
  [Loki storage](../infra/rustfs/loki/README.md) and
  [Terraform S3 backend](../infra/rustfs/tf-s3-backend/README.md).
- NixOS installation: [installer guide](../nixos-installer/README.md) and
  [Shoukei notes](../nixos-installer/README.shoukei.md).
- Certificates: [certificate setup](../certs/README.md).

## Configuration structure

- [NixOS and nix-darwin modules](../modules/README.md), including
  [Darwin modules](../modules/darwin/README.md),
  [Mihomo networking](../modules/nixos/desktop/networking/mihomo/README.md) and
  [Sunshine](../modules/nixos/desktop/networking/sunshine/README.md).
- [Home Manager modules](../home/README.md).
- [Flake outputs and tests](../outputs/README.md).
- [Secrets management](../secrets/README.md).
- [Overlays](../overlays/README.md), [shared library helpers](../lib/README.md) and
  [shared variables](../vars/README.md).
- [Hardening wrappers and policy](../hardening/README.md).

## Desktop and Home Manager details

- [Darwin](../home/darwin/README.md), [per-host Home Manager profiles](../home/hosts/README.md) and
  [Linux](../home/linux/README.md).
- [Linux desktop stack](../home/linux/gui/README.md): [base GUI](../home/linux/gui/base/README.md),
  [Fcitx5](../home/linux/gui/base/fcitx5/README.md),
  [hypridle](../home/linux/gui/base/hypridle/README.md),
  [vinput](../home/linux/gui/base/vinput/README.md) and [i3](../home/linux/gui/i3/README.md).
- [Base Home Manager profile](../home/base/README.md):
  [editors](../home/base/core/editors/README.md),
  [editor glossary](../home/base/core/editors/Glossary.md),
  [Helix](../home/base/core/editors/helix/README.md),
  [Neovim](../home/base/core/editors/neovim/README.md), [Rime](../home/base/gui/rime/README.md) and
  [terminal](../home/base/gui/terminal/README.md).
- Terminal tools: [agents](../home/base/tui/agents/README.md) and
  [dsh notes](../home/base/tui/agents/dsh.md), [editors](../home/base/tui/editors/README.md),
  [encryption](../home/base/tui/encryption/README.md), [GPG](../home/base/tui/gpg/README.md) and
  [password store](../home/base/tui/password-store/README.md).

## Agent resources

- [Global rules, skills and evaluations](../agents/README.md).
- [Skill catalog](../agents/skills/README.md).
- [Global agent rules](../agents/global-rules.md),
  [evaluation guide](../agents/evals/global-rules.md) and
  [tooling installation notes](../agents/install-tooling.md).
