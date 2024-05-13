# just is a command runner, Justfile is very similar to Makefile, but simpler.

# use nushell for shell commands
set shell := ["nu", "-c"]

############################################################################
#
#  Common commands(suitable for all machines)
#
############################################################################

# Remote deployment via colmena
col tag:
  colmena apply --on '@{{tag}}' --verbose --show-trace

local name mode="default":
  use utils.nu *; \
  nixos-switch {{name}} {{mode}}

# Run eval tests
test:
  nix eval .#evalTests --show-trace --print-build-logs --verbose

# update all the flake inputs
up:
  nix flake update

# Update specific input
# Usage: just upp nixpkgs
upp input:
  nix flake update {{input}}

# List all generations of the system profile
history:
  nix profile history --profile /nix/var/nix/profiles/system

# Open a nix shell with the flake
repl:
  nix repl -f flake:nixpkgs

# remove all generations older than 7 days
clean:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

# Garbage collect all unused nix store entries
gc:
  # garbage collect all unused nix store entries
  sudo nix store gc --debug
  sudo nix-collect-garbage --delete-old

# Remove all reflog entries and prune unreachable objects
gitgc:
  git reflog expire --expire-unreachable=now --all
  git gc --prune=now

############################################################################
#
#  NixOS Desktop related commands
#
############################################################################

[linux]
i3 mode="default":
  use utils.nu *; \
  nixos-switch ai-i3 {{mode}}

[linux]
hypr mode="default":
  use utils.nu *; \
  nixos-switch ai-hyprland {{mode}}


[linux]
s-i3 mode="default":
  use utils.nu *; \
  nixos-switch shoukei-i3 {{mode}}

[linux]
s-hypr mode="default":
  use utils.nu *; \
  nixos-switch shoukei-hyprland {{mode}}

############################################################################
#
#  Darwin related commands, harmonica is my macbook pro's hostname
#
############################################################################

[macos]
darwin-set-proxy:
  sudo python3 scripts/darwin_set_proxy.py
  sleep 1sec

[macos]
darwin-rollback:
  use utils.nu *; \
  darwin-rollback

# Deploy to harmonica(macOS host)
[macos]
ha mode="default":
  use utils.nu *; \
  darwin-build "harmonica" {{mode}}; \
  darwin-switch "harmonica" {{mode}}

# Depoly to fern(macOS host)
[macos]
fe mode="default": darwin-set-proxy
  use utils.nu *; \
  darwin-build "fern" {{mode}}; \
  darwin-switch "fern" {{mode}}

# Reload yabai and skhd(macOS)
[macos]
yabai-reload:
  launchctl kickstart -k "gui/502/org.nixos.yabai";
  launchctl kickstart -k "gui/502/org.nixos.skhd"; 

############################################################################
#
#  Homelab - Kubevirt Cluster related commands
#
############################################################################

# Build and upload a vm image
upload-vm name mode="default":
  use utils.nu *; \
  upload-vm {{name}} {{mode}}

# Deploy all the KubeVirt nodes(Physical machines running KubeVirt)
lab:
  colmena apply --on '@virt-*' --verbose --show-trace

shoryu:
  colmena apply --on '@kubevirt-shoryu' --verbose --show-trace

shoryu-local mode="default":
  use utils.nu *; \
  nixos-switch kubevirt-shoryu {{mode}}

shushou:
  colmena apply --on '@kubevirt-shushou' --verbose --show-trace

shushou-local mode="default":
  use utils.nu *; \
  nixos-switch kubevirt-shushou {{mode}}

youko:
  colmena apply --on '@kubevirt-youko' --verbose --show-trace

youko-local mode="default":
  use utils.nu *; \
  nixos-switch kubevirt-youko {{mode}}

############################################################################
#
# Commands for other Virtual Machines
#
############################################################################

# Build and upload a vm image
upload-idols mode="default":
  use utils.nu *; \
  upload-vm aquamarine {{mode}}
  upload-vm ruby {{mode}}
  upload-vm kana {{mode}}

aqua:
  colmena apply --on '@aqua' --verbose --show-trace

aqua-local mode="default":
  use utils.nu *; \
  nixos-switch aquamarine {{mode}}

ruby:
  colmena apply --on '@ruby' --verbose --show-trace

ruby-local mode="default":
  use utils.nu *; \
  nixos-switch ruby {{mode}}

kana:
  colmena apply --on '@kana' --verbose --show-trace

kana-local mode="default":
  use utils.nu *; \
  nixos-switch kana {{mode}}

############################################################################
#
# Kubernetes related commands
#
############################################################################

# Build and upload a vm image
upload-k3s mode="default":
  use utils.nu *; \
  upload-vm k3s-prod-1-master-1 {{mode}}; \
  upload-vm k3s-prod-1-master-2 {{mode}}; \
  upload-vm k3s-prod-1-master-3 {{mode}}; \
  upload-vm k3s-prod-1-worker-1 {{mode}}; \
  upload-vm k3s-prod-1-worker-2 {{mode}}; \
  upload-vm k3s-prod-1-worker-3 {{mode}};

upload-k3s-test mode="default":
  use utils.nu *; \
  upload-vm k3s-test-1-master-1 {{mode}}; \
  upload-vm k3s-test-1-master-2 {{mode}}; \
  upload-vm k3s-test-1-master-3 {{mode}};

k3s:
  colmena apply --on '@k3s-*' --verbose --show-trace

master:
  colmena apply --on '@k3s-prod-1-master-*' --verbose --show-trace

worker:
  colmena apply --on '@k3s-prod-1-worker-*' --verbose --show-trace

k3s-test:
  colmena apply --on '@k3s-test-*' --verbose --show-trace

############################################################################
#
#  RISC-V related commands
#
############################################################################

riscv:
  colmena apply --on '@riscv' --verbose --show-trace

nozomi:
  colmena apply --on '@nozomi' --verbose --show-trace

yukina:
  colmena apply --on '@yukina' --verbose --show-trace

############################################################################
#
# Aarch64 related commands
#
############################################################################

rakushun:
  colmena apply --on '@rakushun' --build-on-target --verbose --show-trace

rakushun-local mode="default":
  use utils.nu *; \
  nixos-switch rakushun {{mode}}

suzu-set-proxy:
  ip route del default via 192.168.5.1
  ip route add default via 192.168.5.178

suzu-unset-proxy:
  ip route del default via 192.168.5.178
  ip route add default via 192.168.5.1

suzu-local mode="default":
  use utils.nu *; \
  nixos-switch suzu {{mode}}

############################################################################
#
#  Misc, other useful commands
#
############################################################################

fmt:
  # format the nix files in this repo
  nix fmt

path:
   $env.PATH | split row ":"

nvim-test:
  rm -rf $"($env.HOME)/.config/nvim"
  rsync -avz --copy-links --chmod=D2755,F744 home/base/tui/editors/neovim/nvim/ $"($env.HOME)/.config/nvim/"

nvim-clean:
  rm -rf $"($env.HOME)/.config/nvim"

# =================================================
# Emacs related commands
# =================================================

emacs-plist-path := "~/Library/LaunchAgents/org.nix-community.home.emacs.plist"

reload-emacs-cmd := if os() == "macos" {
    "launchctl unload " + emacs-plist-path
    + "\n"
    + "launchctl load " + emacs-plist-path
    + "\n"
    + "tail -f ~/Library/Logs/emacs-daemon.stderr.log"
  } else {
    "systemctl --user restart emacs.service"
    + "\n"
    + "systemctl --user status emacs.service"
  }

emacs-test:
  rm -rf $"($env.HOME)/.config/doom"
  rsync -avz --copy-links --chmod=D2755,F744 home/base/tui/editors/emacs/doom/ $"($env.HOME)/.config/doom/"
  doom clean
  doom sync

emacs-clean:
  rm -rf $"($env.HOME)/.config/doom/"

emacs-purge:
  doom purge
  doom clean
  doom sync

emacs-reload:
  doom sync
  {{reload-emacs-cmd}}


# =================================================
#
# Kubernetes related commands
#
# =================================================


del-failed:
   kubectl delete pod --all-namespaces --field-selector="status.phase==Failed"
