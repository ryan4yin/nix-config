# Host - AI

disk status & mountpoints:

```bash
› df -Th
Filesystem                Type      Size  Used Avail Use% Mounted on
devtmpfs                  devtmpfs  1.6G     0  1.6G   0% /dev
tmpfs                     tmpfs      16G  8.0K   16G   1% /dev/shm
tmpfs                     tmpfs     7.8G  7.9M  7.8G   1% /run
tmpfs                     tmpfs      16G  1.1M   16G   1% /run/wrappers
tmpfs                     tmpfs      16G  1.1M   16G   1% /
/dev/mapper/crypted-nixos btrfs     1.9T  468G  1.4T  26% /persistent
/dev/mapper/crypted-nixos btrfs     1.9T  468G  1.4T  26% /nix
tmpfs                     tmpfs     4.0M     0  4.0M   0% /sys/fs/cgroup
/dev/mapper/crypted-nixos btrfs     1.9T  468G  1.4T  26% /snapshots
/dev/mapper/crypted-nixos btrfs     1.9T  468G  1.4T  26% /swap
/dev/nvme0n1p1            vfat      597M   57M  541M  10% /boot
tmpfs                     tmpfs     3.2G   44K  3.2G   1% /run/user/132
//192.168.5.194/Downloads cifs      3.7T  3.0T  706G  82% /home/ryan/SMB-Downloads
tmpfs                     tmpfs     100K     0  100K   0% /var/lib/lxd/shmounts
tmpfs                     tmpfs     100K     0  100K   0% /var/lib/lxd/devlxd
tmpfs                     tmpfs     3.2G   36K  3.2G   1% /run/user/1000

› lsblk
NAME              MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINTS
nvme1n1           259:0    0  1.9T  0 disk
├─nvme1n1p1       259:4    0   16M  0 part
└─nvme1n1p2       259:5    0  1.9T  0 part
nvme0n1           259:1    0  1.8T  0 disk
├─nvme0n1p1       259:2    0  598M  0 part  /boot
└─nvme0n1p2       259:3    0  1.8T  0 part
  └─crypted-nixos 254:0    0  1.8T  0 crypt /swap/swapfile
                                            /swap
                                            /snapshots
                                            /home/ryan/tmp
                                            /home/ryan/nix-config
                                            /home/ryan/go
                                            /home/ryan/codes
                                            /home/ryan/Videos
                                            /home/ryan/Pictures
                                            /home/ryan/Music
                                            /home/ryan/Downloads
                                            /home/ryan/Documents
                                            /home/ryan/.wakatime
                                            /home/ryan/.ssh
                                            /home/ryan/.pki
                                            /home/ryan/.npm
                                            /home/ryan/.mozilla
                                            /home/ryan/.local/state
                                            /home/ryan/.local/share
                                            /home/ryan/.kube
                                            /home/ryan/.gnupg
                                            /home/ryan/.docker
                                            /home/ryan/.config/remmina
                                            /home/ryan/.config/pulse
                                            /home/ryan/.config/google-chrome
                                            /home/ryan/.config/github-copilot
                                            /home/ryan/.config/freerdp
                                            /home/ryan/.aws
                                            /etc/ssh
                                            /etc/secureboot
                                            /etc/nix/inputs
                                            /etc/agenix
                                            /etc/NetworkManager/system-connections
                                            /etc/machine-id
                                            /home/ryan/.config/nushell/history.txt
                                            /home/ryan/.wakatime.cfg
                                            /nix/store
                                            /var/log
                                            /var/lib
                                            /nix
                                            /persistent
```
