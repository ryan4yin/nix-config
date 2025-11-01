# just is a command runner, Justfile is very similar to Makefile, but simpler.

# Use nushell for shell commands
# To use this justfile, you need to enter a shell with just & nushell installed:
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
  nix flake update --commit-lock-file

# Update specific input
# Usage: just upp nixpkgs
[group('nix')]
upp input:
  nix flake update {{input}} --commit-lock-file

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
  # Wipe out NixOS's history
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d
  # Wipe out home-manager's history
  nix profile wipe-history --profile $"($env.XDG_STATE_HOME)/nix/profiles/home-manager" --older-than 7d

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
  ls **/*.nix | each { |it| nixfmt $it.name }

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

# Update all Nixpkgs inputs
[group('nix')]
up-nix:
  nix flake update nixpkgs nixpkgs-stable nixpkgs-unstable nixpkgs-darwin nixpkgs-patched

############################################################################
#
#  NixOS Desktop related commands
#
############################################################################

# Deploy the nixosConfiguration by hostname match
[linux]
[group('homelab')]
local mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *;
  nixos-switch (hostname) {{mode}}

# Deploy the hyprland nixosConfiguration by hostname match
[linux]
[group('desktop')]
hypr mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *;
  nixos-switch $"(hostname)-hyprland" {{mode}}

# Deploy the niri nixosConfiguration by hostname match
[linux]
[group('desktop')]
niri mode="default":
  #!/usr/bin/env nu
  use {{utils_nu}} *;
  nixos-switch $"(hostname)-niri" {{mode}}

############################################################################
#
#  Darwin related commands
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

# Deploy the darwinConfiguration by hostname match
[macos]
[group('desktop')]
local mode="default": 
  #!/usr/bin/env nu
  use {{utils_nu}} *;
  darwin-build (hostname) {{mode}};
  darwin-switch (hostname) {{mode}}


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
shushou:
  colmena apply --on '@kubevirt-shushou' --verbose --show-trace

[linux]
[group('homelab')]
youko:
  colmena apply --on '@kubevirt-youko' --verbose --show-trace

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
ruby:
  colmena apply --on '@ruby' --verbose --show-trace

[linux]
[group('homelab')]
kana:
  colmena apply --on '@kana' --verbose --show-trace

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


# =================================================
#
# Nixpkgs Review via Github Action
# https://github.com/ryan4yin/nixpkgs-review-gha
#
# =================================================

# Run nixpkgs-review for PR
[linux]
[group('nixpkgs')]
pkg-review pr:
  gh workflow run review.yml --repo ryan4yin/nixpkgs-review-gha -f x86_64-darwin=no -f post-result=true -f pr={{pr}}

# Run package tests for PR
[linux]
[group('nixpkgs')]
pkg-test pr pname:
  gh workflow run review.yml --repo ryan4yin/nixpkgs-review-gha -f x86_64-darwin=no -f post-result=true -f pr={{pr}} -f extra-args="-p {{pname}}.passthru.tests"

# View the summary of a workflow
[linux]
[group('nixpkgs')]
pkg-summary:
  gh workflow view review.yml --repo ryan4yin/nixpkgs-review-gha
