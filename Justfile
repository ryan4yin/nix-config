# just is a command runner, Justfile is very similar to Makefile, but simpler.

# use nushell for shell commands
set shell := ["nu", "-c"]

############################################################################
#
#  Nix commands related to the local machine
#
############################################################################

i3 mode="default":
  use utils.nu *; \
  nixos-switch ai_i3 {{mode}}

hypr mode="default":
  use utils.nu *; \
  nixos-switch ai_hyprland {{mode}}


s-i3 mode="default":
  use utils.nu *; \
  nixos-switch shoukei_i3 {{mode}}


s-hypr mode="default":
  use utils.nu *; \
  nixos-switch shoukei_hyprland {{mode}}


up:
  nix flake update

# Update specific input
# Usage: just upp nixpkgs
upp input:
  nix flake lock --update-input {{input}}

history:
  nix profile history --profile /nix/var/nix/profiles/system

repl:
  nix repl -f flake:nixpkgs

clean:
  # remove all generations older than 7 days
  sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

gc:
  # garbage collect all unused nix store entries
  sudo nix store gc --debug

############################################################################
#
#  Darwin related commands, harmonica is my macbook pro's hostname
#
############################################################################

darwin-set-proxy:
  sudo python3 scripts/darwin_set_proxy.py
  sleep 1sec

darwin-rollback:
  rollback

ha mode="default": darwin-set-proxy
  use utils.nu *; \
  darwin-build "harmonica" {{mode}}; \
  darwin-switch "harmonica" {{mode}}

fe mode="default":
  use utils.nu *; \
  darwin-build "fern" {{mode}}; \
  darwin-switch "fern" {{mode}}

############################################################################
#
#  Idols, Commands related to my remote distributed building cluster
#
############################################################################

idols-ssh-key:
  ssh-add ~/.ssh/ai-idols

idols: idols-ssh-key
  colmena apply --on '@dist-build'

aqua:
  colmena apply --on '@aqua'

ruby:
  colmena apply --on '@ruby'

kana:
  colmena apply --on '@kana'

idols-debug: idols-ssh-key
  colmena apply --on '@dist-build' --verbose --show-trace

# only used once to setup the virtual machines
idols-image:
  # take image for idols, and upload the image to proxmox nodes.
  nom build .#aquamarine
  scp result root@gtr5:/var/lib/vz/dump/vzdump-qemu-aquamarine.vma.zst

  nom build .#ruby
  scp result root@s500plus:/var/lib/vz/dump/vzdump-qemu-ruby.vma.zst

  nom build .#kana
  scp result root@um560:/var/lib/vz/dump/vzdump-qemu-kana.vma.zst


############################################################################
#
#  RISC-V related commands
#    
############################################################################

roll: idols-ssh-key
  colmena apply --on '@riscv' 

roll-debug: idols-ssh-key
  colmena apply --on '@dist-build' --verbose --show-trace

nozomi:
  colmena apply --on '@nozomi'

yukina:
  colmena apply --on '@yukina'

############################################################################
#
# Aarch64 related commands
#
############################################################################

aarch:
  colmena apply --on '@aarch'

suzu:
  colmena apply --on '@suzu'

suzu-debug:
  colmena apply --on '@suzu' --verbose --show-trace

############################################################################
#
#  Misc, other useful commands
#
############################################################################

fmt:
  # format the nix files in this repo
  nix fmt

