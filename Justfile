# just is a command runner, Justfile is very similar to Makefile, but simpler.

# use nushell for shell commands
set shell := ["nu", "-c"]

utils_nu := absolute_path("utils.nu")

############################################################################
#
#  Common commands(suitable for all machines)
#
############################################################################

# Run eval tests
[group('nix')]
test:
  nix eval .#evalTests --show-trace --print-build-logs --verbose

# update all the flake inputs
[group('nix')]
up:
  nix flake update

# Update specific input
# Usage: just upp nixpkgs
[group('nix')]
upp input:
  nix flake update {{input}}

# List all generations of the system profile
[group('nix')]
history:
  nix profile history --profile /nix/var/nix/profiles/system

# Open a nix shell with the flake
[group('nix')]
repl:
  nix repl -f flake:nixpkgs

# remove all generations older than 7 days
[group('nix')]
clean:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

# Garbage collect all unused nix store entries
[group('nix')]
gc:
  # garbage collect all unused nix store entries
  sudo nix-collect-garbage --delete-old

# Enter a shell session which has all the necessary tools for this flake
[linux]
[group('nix')]
shell:
  nix shell nixpkgs#just nixpkgs#nushell nixpkgs#colmena

# Enter a shell session which has all the necessary tools for this flake
[macos]
[group('nix')]
shell:
  nix shell nixpkgs#just nixpkgs#nushell

[group('nix')]
fmt:
  # format the nix files in this repo
  nix fmt

############################################################################
#
#  NixOS Desktop related commands
#
############################################################################

[linux]
[group('desktop')]
i3 mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *;
  nixos-switch ai-i3 {{mode}}

[linux]
[group('desktop')]
hypr mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *;
  nixos-switch ai-hyprland {{mode}}


[linux]
[group('desktop')]
s-i3 mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *;
  nixos-switch shoukei-i3 {{mode}}

[linux]
[group('desktop')]
s-hypr mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *;
  nixos-switch shoukei-hyprland {{mode}}

############################################################################
#
#  Darwin related commands, harmonica is my macbook pro's hostname
#
############################################################################

[macos]
[group('desktop')]
darwin-set-proxy:
  sudo python3 scripts/darwin_set_proxy.py
  sleep 1sec

[macos]
[group('desktop')]
darwin-rollback:
  #!/usr/bin/env nu
  use {{utils_nu}} *;
  darwin-rollback

# Deploy to harmonica(macOS host)
[macos]
[group('desktop')]
ha mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *;
  darwin-build "harmonica" {{mode}};
  darwin-switch "harmonica" {{mode}}

# Depoly to fern(macOS host)
[macos]
[group('desktop')]
fe mode="default": darwin-set-proxy
  #!/usr/bin/env nu
  use {{utils_nu}} *;
  darwin-build "fern" {{mode}};
  darwin-switch "fern" {{mode}}

# Reload yabai and skhd(macOS)
[macos]
[group('desktop')]
yabai-reload:
  launchctl kickstart -k "gui/502/org.nixos.yabai";
  launchctl kickstart -k "gui/502/org.nixos.skhd"; 

############################################################################
#
#  Homelab - Kubevirt Cluster related commands
#
############################################################################

# Remote deployment via colmena
[linux]
[group('homelab')]
col tag:
  colmena apply --on '@{{tag}}' --verbose --show-trace

[linux]
[group('homelab')]
local name mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *;
  nixos-switch {{name}} {{mode}}

# Build and upload a vm image
[linux]
[group('homelab')]
upload-vm name mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *;
  upload-vm {{name}} {{mode}}

# Deploy all the KubeVirt nodes(Physical machines running KubeVirt)
[linux]
[group('homelab')]
lab:
  colmena apply --on '@virt-*' --verbose --show-trace

[linux]
[group('homelab')]
shoryu:
  colmena apply --on '@kubevirt-shoryu' --verbose --show-trace

[linux]
[group('homelab')]
shoryu-local mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *; 
  nixos-switch kubevirt-shoryu {{mode}}

[linux]
[group('homelab')]
shushou:
  colmena apply --on '@kubevirt-shushou' --verbose --show-trace

[linux]
[group('homelab')]
shushou-local mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *; 
  nixos-switch kubevirt-shushou {{mode}}

[linux]
[group('homelab')]
youko:
  colmena apply --on '@kubevirt-youko' --verbose --show-trace

[linux]
[group('homelab')]
youko-local mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *; 
  nixos-switch kubevirt-youko {{mode}}

############################################################################
#
# Commands for other Virtual Machines
#
############################################################################

# Build and upload a vm image
[linux]
[group('homelab')]
upload-idols mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *; 
  upload-vm aquamarine {{mode}}
  upload-vm ruby {{mode}}
  upload-vm kana {{mode}}

[linux]
[group('homelab')]
aqua:
  colmena apply --on '@aqua' --verbose --show-trace

[linux]
[group('homelab')]
aqua-local mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *; 
  nixos-switch aquamarine {{mode}}

[linux]
[group('homelab')]
ruby:
  colmena apply --on '@ruby' --verbose --show-trace

[linux]
[group('homelab')]
ruby-local mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *; 
  nixos-switch ruby {{mode}}

[linux]
[group('homelab')]
kana:
  colmena apply --on '@kana' --verbose --show-trace

[linux]
[group('homelab')]
kana-local mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *; 
  nixos-switch kana {{mode}}

############################################################################
#
# Kubernetes related commands
#
############################################################################

# Build and upload a vm image
[linux]
[group('homelab')]
upload-k3s mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *; 
  upload-vm k3s-prod-1-master-1 {{mode}}; 
  upload-vm k3s-prod-1-master-2 {{mode}}; 
  upload-vm k3s-prod-1-master-3 {{mode}}; 
  upload-vm k3s-prod-1-worker-1 {{mode}}; 
  upload-vm k3s-prod-1-worker-2 {{mode}}; 
  upload-vm k3s-prod-1-worker-3 {{mode}};

[linux]
[group('homelab')]
upload-k3s-test mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *; 
  upload-vm k3s-test-1-master-1 {{mode}}; 
  upload-vm k3s-test-1-master-2 {{mode}}; 
  upload-vm k3s-test-1-master-3 {{mode}};

[linux]
[group('homelab')]
k3s:
  colmena apply --on '@k3s-*' --verbose --show-trace

[linux]
[group('homelab')]
master:
  colmena apply --on '@k3s-prod-1-master-*' --verbose --show-trace

[linux]
[group('homelab')]
worker:
  colmena apply --on '@k3s-prod-1-worker-*' --verbose --show-trace

[linux]
[group('homelab')]
k3s-test:
  colmena apply --on '@k3s-test-*' --verbose --show-trace

############################################################################
#
#  RISC-V related commands
#
############################################################################

[linux]
[group('homelab')]
riscv:
  colmena apply --on '@riscv' --verbose --show-trace

[linux]
[group('homelab')]
nozomi:
  colmena apply --on '@nozomi' --verbose --show-trace

[linux]
[group('homelab')]
yukina:
  colmena apply --on '@yukina' --verbose --show-trace

############################################################################
#
# Aarch64 related commands
#
############################################################################

[linux]
[group('homelab')]
rakushun:
  colmena apply --on '@rakushun' --build-on-target --verbose --show-trace

[linux]
[group('homelab')]
rakushun-local mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *; 
  nixos-switch rakushun {{mode}}

[linux]
[group('homelab')]
suzu-set-proxy:
  ip route del default via 192.168.5.1
  ip route add default via 192.168.5.178

[linux]
[group('homelab')]
suzu-unset-proxy:
  ip route del default via 192.168.5.178
  ip route add default via 192.168.5.1

[linux]
[group('homelab')]
suzu-local mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *; 
  nixos-switch suzu {{mode}}

############################################################################
#
#  Neovim related commands
#
############################################################################

[group('neovim')]
nvim-test:
  rm -rf $"($env.HOME)/.config/nvim"
  rsync -avz --copy-links --chmod=D2755,F744 home/base/tui/editors/neovim/nvim/ $"($env.HOME)/.config/nvim/"

[group('neovim')]
nvim-clean:
  rm -rf $"($env.HOME)/.config/nvim"

# =================================================
# Emacs related commands
# =================================================

[group('emacs')]
emacs-test:
  rm -rf $"($env.HOME)/.config/doom"
  rsync -avz --copy-links --chmod=D2755,F744 home/base/tui/editors/emacs/doom/ $"($env.HOME)/.config/doom/"
  doom clean
  doom sync

[group('emacs')]
emacs-clean:
  rm -rf $"($env.HOME)/.config/doom/"

[group('emacs')]
emacs-purge:
  doom purge
  doom clean
  doom sync

[linux]
[group('emacs')]
emacs-reload:
  doom sync
  systemctl --user restart emacs.service
  systemctl --user status emacs.service


emacs-plist-path := "~/Library/LaunchAgents/org.nix-community.home.emacs.plist"

[macos]
[group('emacs')]
emacs-reload:
  doom sync
  launchctl unload {{emacs-plist-path}}
  launchctl load {{emacs-plist-path}}
  tail -f ~/Library/Logs/emacs-daemon.stderr.log

# =================================================
#
# Other useful commands
#
# =================================================

[group('common')]
path:
   $env.PATH | split row ":"

[linux]
[group('common')]
penvof pid:
  sudo cat $"/proc/($pid)/environ" | tr '\0' '\n'

# Remove all reflog entries and prune unreachable objects
[group('git')]
gitgc:
  git reflog expire --expire-unreachable=now --all
  git gc --prune=now

# Delete all failed pods
[group('k8s')]
del-failed:
   kubectl delete pod --all-namespaces --field-selector="status.phase==Failed"
