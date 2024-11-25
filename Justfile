# just is a command runner, Justfile is very similar to Makefile, but simpler.

# Use nushell for shell commands
# To usage this justfile, you need to enter a shell with just & nushell installed:
# 
#   nix shell nixpkgs#just nixpkgs#nushell
set shell := ["nu", "-c"]

utils_nu := absolute_path("utils.nu")

############################################################################
#
#  Common commands(suitable for all machines)
#
############################################################################

# List all the just commands
default:
    @just --list

# Run eval tests
[group('nix')]
test:
  nix eval .#evalTests --show-trace --print-build-logs --verbose

# Update all the flake inputs
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
# on darwin, you may need to switch to root user to run this command
[group('nix')]
clean:
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

# Garbage collect all unused nix store entries
[group('nix')]
gc:
  # garbage collect all unused nix store entries(system-wide)
  sudo nix-collect-garbage --delete-older-than 7d
  # garbage collect all unused nix store entries(for the user - home-manager)
  # https://github.com/NixOS/nix/issues/8508
  nix-collect-garbage --delete-older-than 7d

# Enter a shell session which has all the necessary tools for this flake
[linux]
[group('nix')]
shell:
  nix shell nixpkgs#git nixpkgs#neovim nixpkgs#colmena

# Enter a shell session which has all the necessary tools for this flake
[macos]
[group('nix')]
shell:
  nix shell nixpkgs#git nixpkgs#neovim

[group('nix')]
fmt:
  # format the nix files in this repo
  nix fmt

# Show all the auto gc roots in the nix store
[group('nix')]
gcroot:
  ls -al /nix/var/nix/gcroots/auto/

# Verify all the store entries
# Nix Store can contains corrupted entries if the nix store object has been modified unexpectedly.
# This command will verify all the store entries,
# and we need to fix the corrupted entries manually via `sudo nix store delete <store-path-1> <store-path-2> ...`
[group('nix')]
verify-store:
  nix store verify --all

# Repair Nix Store Objects
[group('nix')]
repair-store *paths:
  nix store repair {{paths}}

############################################################################
#
#  NixOS Desktop related commands
#
############################################################################

[linux]
[group('desktop')]
hypr mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *;
  nixos-switch ai-hyprland {{mode}}

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

# Reset launchpad to force it to reindex Applications
[macos]
[group('desktop')]
reset-launchpad:
  defaults write com.apple.dock ResetLaunchPad -bool true
  killall Dock

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
upload-k3s-prod mode="default":
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
k3s-prod:
  colmena apply --on '@k3s-prod-*' --verbose --show-trace

[linux]
[group('homelab')]
k3s-test:
  colmena apply --on '@k3s-test-*' --verbose --show-trace

# =================================================
# Emacs related commands
# =================================================

[group('emacs')]
emacs-test:
  doom clean
  doom sync

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

[group('common')]
trace-access app *args:
  strace -f -t -e trace=file {{app}} {{args}} | complete | $in.stderr | lines | find -v -r "(/nix/store|/newroot|/proc)" | parse --regex '"(/.+)"' | sort | uniq

[linux]
[group('common')]
penvof pid:
  sudo cat $"/proc/($pid)/environ" | tr '\0' '\n'

# Remove all reflog entries and prune unreachable objects
[group('git')]
ggc:
  git reflog expire --expire-unreachable=now --all
  git gc --prune=now

# Amend the last commit without changing the commit message
[group('git')]
game:
  git commit --amend -a --no-edit

# Delete all failed pods
[group('k8s')]
del-failed:
  kubectl delete pod --all-namespaces --field-selector="status.phase==Failed"

[linux]
[group('services')]
list-inactive:
  systemctl list-units -all --state=inactive

[linux]
[group('services')]
list-failed:
  systemctl list-units -all --state=failed

[linux]
[group('services')]
list-systemd:
  systemctl list-units systemd-*
