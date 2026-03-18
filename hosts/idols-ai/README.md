# Host - AI

Desktop (NixOS + preservation, LUKS + btrfs on nvme). Disk layout is declarative via
[disko](./disko-fs.nix) (target device: **nvme1n1**).

Related:

- [nixos-installer README](/nixos-installer/README.md) – install from ISO using disko
- [disko-fs.nix](./disko-fs.nix) – main disk layout (ESP + LUKS + btrfs). From
  `nix-config/nixos-installer`:  
  `nix run github:nix-community/disko -- --mode destroy,format,mount ../hosts/idols-ai/disko-fs.nix`
- [disko-fs-media.nix](./disko-fs-media.nix) – media disk layout (LUKS + btrfs at /persistent/media)

## TODOs

1. Install DCGM-Exporter on `ai` to monitor the GPU status.

## Info

Current disk status and mountpoints (example; after migration layout is on nvme1n1):

```bash
› df -Th
Filesystem                Type      Size  Used Avail Use% Mounted on
devtmpfs                  devtmpfs  1.6G     0  1.6G   0% /dev
tmpfs                     tmpfs      16G  8.0K   16G   1% /dev/shm
tmpfs                     tmpfs     7.8G  7.9M  7.8G   1% /run
tmpfs                     tmpfs      16G  1.1M   16G   1% /run/wrappers
tmpfs                     tmpfs      16G   87M   16G   1% /
/dev/mapper/crypted-nixos btrfs     1.9T  630G  1.3T  34% /persistent
/dev/mapper/crypted-nixos btrfs     1.9T  630G  1.3T  34% /nix
tmpfs                     tmpfs     4.0M     0  4.0M   0% /sys/fs/cgroup
efivarfs                  efivarfs  256K  108K  144K  43% /sys/firmware/efi/efivars
/dev/mapper/crypted-nixos btrfs     1.9T  630G  1.3T  34% /snapshots
/dev/mapper/crypted-nixos btrfs     1.9T  630G  1.3T  34% /swap
/dev/nvme0n1p1            vfat      597M  108M  490M  19% /boot
tmpfs                     tmpfs     3.2G   48K  3.2G   1% /run/user/1000
//192.168.5.194/Downloads cifs      3.7T  3.0T  699G  82% /home/ryan/SMB-Downloads
tmpfs                     tmpfs     100K     0  100K   0% /var/lib/lxd/shmounts
tmpfs                     tmpfs     100K     0  100K   0% /var/lib/lxd/devlxd
/dev/mapper/crypted-nixos btrfs     1.9T  630G  1.3T  34% /tmp

~
› lsblk
NAME              MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS
nvme0n1           259:0    0  1.8T  0 disk
├─nvme0n1p1       259:1    0  598M  0 part  /boot
└─nvme0n1p2       259:2    0  1.8T  0 part
  └─crypted-nixos 254:0    0  1.8T  0 crypt /swap/swapfile
                                            /gnu/store
                                            /swap
                                            /tmp
                                            /snapshots
                                            /gnu
                                            /btr_pool
                                            /var/log
                                            /var/lib/qemu
                                            /var/lib/tailscale
                                            /var/lib/systemd
                                            /var/lib/private
                                            /var/lib/nixos
                                            /var/lib/lxd
                                            /var/lib/netbird-homelab
                                            /var/lib/lxc
                                            /var/lib/libvirt
                                            /var/lib/iwd
                                            /var/lib/flatpak
                                            /var/lib/containers
                                            /var/lib/cni
                                            /var/lib/NetworkManager
                                            /var/lib/bluetooth
                                            /home/ryan/work
                                            /home/ryan/nix-config
                                            /home/ryan/tmp
                                            /home/ryan/go
                                            /home/ryan/codes
                                            /home/ryan/Videos
                                            /home/ryan/Pictures
                                            /home/ryan/Music
                                            /home/ryan/Games
                                            /home/ryan/Downloads
                                            /home/ryan/.zoom
                                            /home/ryan/Documents
                                            /home/ryan/.wakatime
                                            /home/ryan/.vscode
                                            /home/ryan/.var
                                            /home/ryan/.terraform.d/plugin-cache
                                            /home/ryan/.steam
                                            /home/ryan/.ssh
                                            /home/ryan/.pulumi
                                            /home/ryan/.pki
                                            /home/ryan/.npm
                                            /home/ryan/.mozilla
                                            /home/ryan/.m2
                                            /home/ryan/.local/state/wireplumber
                                            /home/ryan/.local/state/nvim
                                            /home/ryan/.local/state/home-manager
                                            /home/ryan/.local/share/uv
                                            /home/ryan/.local/state/Heroic
                                            /home/ryan/.local/state/nix/profiles
                                            /home/ryan/.local/share/zoxide
                                            /home/ryan/.local/share/umu
                                            /home/ryan/.local/share/tiled
                                            /home/ryan/.local/share/steel
                                            /home/ryan/.local/share/remmina
                                            /home/ryan/.local/share/password-store
                                            /home/ryan/.local/share/opencode
                                            /home/ryan/.local/share/nvim
                                            /home/ryan/.local/share/nix
                                            /home/ryan/.local/share/krita
                                            /home/ryan/.local/share/lutris
                                            /home/ryan/.local/share/keyrings
                                            /home/ryan/.local/share/k9s
                                            /home/ryan/.local/share/jupyter
                                            /home/ryan/.local/share/flatpak
                                            /home/ryan/.local/share/io.github.clash-verge-rev.clash-verge-rev
                                            /home/ryan/.local/share/feral-interactive
                                            /home/ryan/.local/share/direnv
                                            /home/ryan/.local/share/clash-verge
                                            /home/ryan/.local/share/containers
                                            /home/ryan/.local/share/atuin
                                            /home/ryan/.local/share/Steam
                                            /home/ryan/.local/share/StardewValley
                                            /home/ryan/.local/share/GOG.com
                                            /home/ryan/.local/bin
                                            /home/ryan/.local/pipx
                                            /home/ryan/.kube
                                            /home/ryan/.gradle
                                            /home/ryan/.gnupg
                                            /home/ryan/.kimi
                                            /home/ryan/.ipython
                                            /home/ryan/.gemini
                                            /home/ryan/.docker
                                            /home/ryan/.config/sunshine
                                            /home/ryan/.cursor
                                            /home/ryan/.context7
                                            /home/ryan/.config/remmina
                                            /home/ryan/.config/pulse
                                            /home/ryan/.config/opencode
                                            /home/ryan/.config/obs-studio
                                            /home/ryan/.config/mozc
                                            /home/ryan/.config/nushell
                                            /home/ryan/.config/lutris
                                            /home/ryan/.config/joplin
                                            /home/ryan/.config/heroic
                                            /home/ryan/.config/google-chrome
                                            /home/ryan/.config/gcloud
                                            /home/ryan/.config/freerdp
                                            /home/ryan/.config/blender
                                            /home/ryan/.config/chromium
                                            /home/ryan/.config/LDtk
                                            /home/ryan/.config/Joplin
                                            /home/ryan/.config/Cursor
                                            /home/ryan/.config/Code
                                            /home/ryan/.conda
                                            /home/ryan/.cargo
                                            /home/ryan/.codex
                                            /home/ryan/.cache
                                            /home/ryan/.aws
                                            /home/ryan/.aliyun
                                            /etc/ssh
                                            /etc/secureboot
                                            /etc/nix/inputs
                                            /etc/NetworkManager/system-connections
                                            /etc/agenix
                                            /etc/netbird-homelab
                                            /nix/store
                                            /etc/machine-id
                                            /persistent
                                            /nix
```
