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
  let result = (nix eval .#evalTests --json --show-trace --print-build-logs --verbose | str trim); if $result != "true" { error make { msg: $"eval tests failed: evalTests returned ($result)" } }

# Build and run the runtime security VM test (needs /dev/kvm; not run by just test)
[linux]
[group('nix')]
test-vm:
  nix build --no-link --print-build-logs .#checks.x86_64-linux.security-exporters

# Evaluate a NixOS host configuration without building it.
[group('nix')]
eval-host host:
  nix eval $".#nixosConfigurations.{{host}}.config.system.build.toplevel.drvPath" --raw --show-trace

# Build a NixOS host system closure without changing the current system.
[group('nix')]
build-host host:
  nix build $".#nixosConfigurations.{{host}}.config.system.build.toplevel" --no-link --print-build-logs

# Build a MicroVM runner locally. microvm-deploy copies the closure to the physical host.
[group('nix')]
build-microvm guest:
  nix build $".#nixosConfigurations.{{guest}}.config.microvm.declaredRunner" --no-link --print-build-logs

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

# remove all old generations
# on darwin, you may need to switch to root user to run this command
[group('nix')]
clean:
  # Wipe out NixOS's history
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system
  # Wipe out home-manager's history
  nix profile wipe-history --profile $"($env.XDG_STATE_HOME)/nix/profiles/home-manager"

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

# upgrade determinate nix
[macos]
[group('nix')]
nix-upgrade:
  sudo determinate-nixd upgrade

[group('nix')]
fmt:
  # format the nix files in this repo
  # (use external find so symlinked dirs like the `result` build output are not followed)
  ^find . -name '*.nix' -not -path './.git/*' | lines | each { |it| nixfmt $it | ignore }

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
  nix flake update --commit-lock-file nixpkgs-stable nixpkgs-master nixpkgs-darwin nixpkgs-patched

# override nixpkgs's commit hash
[group('nix')]
override-pkgs hash:
  nix flake update --commit-lock-file nixpkgs --override-input nixpkgs github:NixOS/nixpkgs/{{hash}}

############################################################################
#
#  NixOS Desktop related commands
#
############################################################################

# Deploy the nixosConfiguration by hostname match
[linux]
[group('homelab')]
local mode="switch" verbosity="normal":
  #!/usr/bin/env nu
  use {{utils_nu}} *;
  nixos-switch (hostname) {{mode}} {{verbosity}}

# Deploy the niri nixosConfiguration by hostname match
[linux]
[group('desktop')]
niri mode="switch" verbosity="normal":
  #!/usr/bin/env nu
  use {{utils_nu}} *;
  nixos-switch $"(hostname)-niri" {{mode}} {{verbosity}}

# Pin shoukei's home Wi-Fi to a static IPv4 (run once; the profile persists).
[linux]
[group('desktop')]
shoukei-home-wifi:
  sudo nu {{absolute_path("scripts/shoukei-home-wifi-static.nu")}}

############################################################################
#
#  Darwin related commands
#
############################################################################

[macos]
[group('desktop')]
brew-upgrade:
  brew upgrade --cask --greedy

[macos]
[group('desktop')]
darwin-rollback:
  #!/usr/bin/env nu
  use {{utils_nu}} *;
  darwin-rollback

# Deploy the darwinConfiguration by hostname match
[macos]
[group('desktop')]
local verbosity="normal":
  #!/usr/bin/env nu
  use {{utils_nu}} *;
  darwin-build (hostname) {{verbosity}};
  darwin-switch (hostname) {{verbosity}}


# Reset launchpad to force it to reindex Applications
[macos]
[group('desktop')]
reset-launchpad:
  defaults write com.apple.dock ResetLaunchPad -bool true
  killall Dock

############################################################################
#
#  Homelab - VM host related commands
#
############################################################################

# Remote deployment via colmena
[linux]
[group('homelab')]
col tag mode="switch":
  colmena apply {{mode}} --on '@{{tag}}' --verbose --show-trace

# Deploy one microVM guest: copy its runner to the physical host, then restart the
# guest unit there. microvm.nix's sshSwitch step is not used: it switches the guest over
# SSH and dies on the read-only virtiofs /nix/store (WA-026 in WORKAROUNDS.md).
# The host is the physical machine running the guest.
[linux]
[group('homelab')]
microvm-deploy guest host:
  nix run $".#nixosConfigurations.{{guest}}.config.microvm.deploy.installOnHost" -- root@{{host}}
  ssh root@{{host}} systemctl restart microvm@{{guest}}

# Deploy all the VM hosts (physical machines running the VMs)
[linux]
[group('homelab')]
lab mode="switch":
  colmena apply {{mode}} --on '@virt-*' --verbose --show-trace

[linux]
[group('homelab')]
shoryu mode="switch":
  colmena apply {{mode}} --on '@shoryu' --verbose --show-trace

[linux]
[group('homelab')]
shushou mode="switch":
  colmena apply {{mode}} --on '@shushou' --verbose --show-trace

[linux]
[group('homelab')]
youko mode="switch":
  colmena apply {{mode}} --on '@youko' --verbose --show-trace

############################################################################
#
# Commands for other Virtual Machines
#
############################################################################

[linux]
[group('homelab')]
ruby mode="switch":
  colmena apply {{mode}} --on '@ruby' --verbose --show-trace

[linux]
[group('homelab')]
kana mode="switch":
  colmena apply {{mode}} --on '@kana' --verbose --show-trace

############################################################################
#
# Kubernetes related commands
#
############################################################################

[linux]
[group('homelab')]
k3s-test mode="switch":
  colmena apply {{mode}} --on '@k3s-test-*' --verbose --show-trace

# =================================================
#
# AI agent commands
#
# =================================================

# Start the dsh web UI without opening a browser, proxied via mihomo's mixed port.
[group('agents')]
dsh-web:
  #!/usr/bin/env nu
  # no_proxy keeps local endpoints out of the proxy; the proxy is here for fake-ip.
  # dsh's web fetch refuses a DNS answer it does not call public and fake-ip answers
  # with 198.18.0.0/15, so a proxied hop makes mihomo resolve the origin instead.
  # That makes mihomo a dependency of every Node fetch the harness makes, so it has
  # to stop at the LAN: without no_proxy this host's own llama-swap endpoint goes
  # through it too. Node reads only lowercase `no_proxy` and matches exact hosts,
  # not CIDR; curl and Go do honor CIDR.
  with-env {
    HTTPS_PROXY: "http://127.0.0.1:7897"
    HTTP_PROXY: "http://127.0.0.1:7897"
    no_proxy: "localhost,127.0.0.1,::1,[::1],192.168.5.100,192.168.5.178,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
    NO_PROXY: "localhost,127.0.0.1,::1,[::1],192.168.5.100,192.168.5.178,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
  } { ^dsh web --no-open }

# Render the mihomo config from this repo and validate it with the live core.
[linux]
[group('services')]
mihomo-gen:
  #!/usr/bin/env nu
  # ~/.config/mihomo holds only the private sources.yaml and the generated
  # config.yaml. The generator and policy.yaml stay in the repository, so the
  # live directory can never keep a stale copy of them.
  let mod = ("{{ justfile() }}" | path dirname | path join modules nixos desktop networking mihomo)
  nu ($mod | path join generate.nu)
  # Validate with the core the service actually runs; a nixpkgs one may differ.
  let core = (systemctl show mihomo.service -p ExecStart | str trim | split row "path=" | get 1 | split row " " | get 0)
  let check = (^$core -t -f ($env.HOME | path join .config mihomo config.yaml) | complete)
  if $check.exit_code != 0 {
    print --stderr ($check.stderr | str trim)
    exit $check.exit_code
  }
  print "validated -- restart: sudo systemctl restart mihomo.service"

# Seed mihomo's geodata into the service's state dir, so a cold start needs no DNS.
[linux]
[group('services')]
mihomo-geo:
  #!/usr/bin/env nu
  # Copy geodata in by hand, so a cold start never has to fetch it. The core
  # fetches it while parsing rules, before its own DNS is up and while the link
  # DNS points at it -- that fetch can only fail.
  let src = ($env.HOME | path join .config mihomo)
  let dst = "/var/lib/private/mihomo"
  sudo mkdir -p $dst
  mut seeded = []
  for f in [GeoSite.dat geoip.metadb ASN.mmdb] {
    let p = ($src | path join $f)
    if ($p | path exists) {
      sudo cp $p $dst
      $seeded = ($seeded | append ($dst | path join $f))
    } else {
      print $"(!) ($f) is not in ($src) -- fetch it first: mihomo -t -d ($src) -f ($src)/config.yaml"
    }
  }
  if ($seeded | is-not-empty) {
    sudo chmod 644 ...$seeded
    let names = ($seeded | path basename | str join ', ')
    print $"seeded ($names) -- restart mihomo to pick them up"
  }

# Render the mihomo config into a Clash Verge Rev local profile on macOS.
# sources.yaml comes from the encrypted dotfiles sync (nix-secrets `just restore`).
[macos]
[group('services')]
mihomo-verge *args:
  #!/usr/bin/env nu
  let mod = ("{{ justfile() }}" | path dirname | path join modules nixos desktop networking mihomo)
  nu ($mod | path join verge-sync.nu) {{ args }}

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

# Start PC VR on idols-ai and route desktop audio to the headset.
[linux]
[group('vr')]
vr:
  systemctl --user start wivrn.service
  systemctl --user stop wivrn-audio.service | complete | ignore
  systemd-run --user --collect --unit=wivrn-audio nu {{absolute_path("scripts/wivrn-audio.nu")}} switch --timeout 600

# Route audio to a headset that is connected right now.
[linux]
[group('vr')]
vr-audio:
  nu {{absolute_path("scripts/wivrn-audio.nu")}} switch --timeout 60

# Stop PC VR when finished and restore the previous audio devices.
[linux]
[group('vr')]
vr-stop:
  systemctl --user stop wivrn-audio.service | complete | ignore
  nu {{absolute_path("scripts/wivrn-audio.nu")}} restore
  systemctl --user stop wivrn.service

# Show PC VR service status.
[linux]
[group('vr')]
vr-status:
  systemctl --user status wivrn.service --no-pager

# Follow PC VR service logs.
[linux]
[group('vr')]
vr-logs:
  journalctl --user -u wivrn.service -f

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
# GitHub CLI + Nixpkgs Review via Github Action
# https://github.com/ryan4yin/nixpkgs-review-gha
#
# =================================================

[group('github')]
gh-login:
  gh auth login -h github.com --skip-ssh-key --git-protocol ssh

# Run nixpkgs-review for PR
[group('nixpkgs')]
pkg-review pr:
  gh workflow run review.yml --repo ryan4yin/nixpkgs-review-gha -f x86_64-darwin=no -f post-result=true -f pr={{pr}}

# Run package tests for PR
[group('nixpkgs')]
pkg-test pr pname:
  gh workflow run review.yml --repo ryan4yin/nixpkgs-review-gha -f x86_64-darwin=no -f post-result=true -f pr={{pr}} -f extra-args="-p {{pname}}.passthru.tests"

# View the summary of a workflow
[group('nixpkgs')]
pkg-summary:
  gh workflow view review.yml --repo ryan4yin/nixpkgs-review-gha
