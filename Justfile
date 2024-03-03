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
  sudo nix-collect-garbage --delete-old

gitgc:
  git reflog expire --expire-unreachable=now --all
  git gc --prune=now

############################################################################
#
#  Darwin related commands, harmonica is my macbook pro's hostname
#
############################################################################

darwin-set-proxy:
  sudo python3 scripts/darwin_set_proxy.py
  sleep 1sec

darwin-rollback:
  use utils.nu *; \
  darwin-rollback

ha mode="default":
  use utils.nu *; \
  darwin-build "harmonica" {{mode}}; \
  darwin-switch "harmonica" {{mode}}

fe mode="default": darwin-set-proxy
  use utils.nu *; \
  darwin-build "fern" {{mode}}; \
  darwin-switch "fern" {{mode}}

yabai-reload:
  launchctl kickstart -k "gui/502/org.nixos.yabai";
  launchctl kickstart -k "gui/502/org.nixos.skhd"; 

############################################################################
#
#  Homelab - NixOS servers running on bare metal
#
############################################################################

virt:
  colmena apply --on '@virt-*' --verbose --show-trace

shoryu:
  colmena apply --on '@shoryu' --verbose --show-trace

shushou:
  colmena apply --on '@shushou' --verbose --show-trace

youko:
  colmena apply --on '@youko' --verbose --show-trace


############################################################################
#
#  Homelab - Virtual Machines running on Kubevirt
#
############################################################################

lab:
  colmena apply --on '@homelab-*' --verbose --show-trace

aqua:
  colmena apply --on '@aqua' --verbose --show-trace
  # some config changes require a restart of the dae service
  ssh ryan@aquamarine "sudo systemctl stop dae; sleep 1; sudo systemctl start dae"

ruby:
  colmena apply --on '@ruby' --verbose --show-trace

kana:
  colmena apply --on '@kana' --verbose --show-trace

tsgw:
  colmena apply --on '@tailscale-gw' --verbose --show-trace

# pve-aqua:
#   nom build .#aquamarine
#   rsync -avz --progress --copy-links result root@um560:/var/lib/vz/dump/vzdump-qemu-aquamarine.vma.zst
#
# pve-ruby:
#   nom build .#ruby
#   rsync -avz --progress --copy-links result root@um560:/var/lib/vz/dump/vzdump-qemu-ruby.vma.zst
#
# pve-kana:
#   nom build .#kana
#   rsync -avz --progress --copy-links result root@gtr5:/var/lib/vz/dump/vzdump-qemu-kana.vma.zst
#
# pve-tsgw:
#   nom build .#tailscale_gw
#   rsync -avz --progress --copy-links result root@um560:/var/lib/vz/dump/vzdump-qemu-tailscale_gw.vma.zst
#

############################################################################
#
# Kubernetes related commands
#
############################################################################

k8s:
  colmena apply --on '@k8s-*' --verbose --show-trace

master:
  colmena apply --on '@k8s-prod-master-*' --verbose --show-trace

worker:
  colmena apply --on '@k8s-prod-worker-*' --verbose --show-trace

# pve-k8s:
#   nom build .#k3s_prod_1_master_1
#   rsync -avz --progress --copy-links result root@um560:/var/lib/vz/dump/vzdump-qemu-k3s_prod_1_master_1.vma.zst
#
#   nom build .#k3s_prod_1_master_2
#   rsync -avz --progress --copy-links result root@gtr5:/var/lib/vz/dump/vzdump-qemu-k3s_prod_1_master_2.vma.zst
#
#   nom build .#k3s_prod_1_master_3
#   rsync -avz --progress --copy-links result root@s500plus:/var/lib/vz/dump/vzdump-qemu-k3s_prod_1_master_3.vma.zst
#
#   nom build .#k3s_prod_1_worker_1
#   rsync -avz --progress --copy-links result root@gtr5:/var/lib/vz/dump/vzdump-qemu-k3s_prod_1_worker_1.vma.zst
#
#   nom build .#k3s_prod_1_worker_2
#   rsync -avz --progress --copy-links result root@s500plus:/var/lib/vz/dump/vzdump-qemu-k3s_prod_1_worker_2.vma.zst
#
#   nom build .#k3s_prod_1_worker_3
#   rsync -avz --progress --copy-links result root@s500plus:/var/lib/vz/dump/vzdump-qemu-k3s_prod_1_worker_3.vma.zst
#

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

aarch:
  colmena apply --on '@aarch' --verbose --show-trace

suzu:
  colmena apply --on '@suzu' --verbose --show-trace

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

path:
   $env.PATH | split row ":"

nvim-test:
  rm -rf $"($env.HOME)/.config/astronvim/lua/user"
  rsync -avz --copy-links --chmod=D2755,F744 home/base/desktop/editors/neovim/astronvim_user/ $"($env.HOME)/.config/astronvim/lua/user"

nvim-clean:
  rm -rf $"($env.HOME)/.config/astronvim/lua/user"

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
  rsync -avz --copy-links --chmod=D2755,F744 home/base/desktop/editors/emacs/doom/ $"($env.HOME)/.config/doom"
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
