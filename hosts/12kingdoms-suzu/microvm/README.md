# microvm.nix

## Commands

> https://github.com/astro/microvm.nix/blob/main/doc/src/microvm-command.md

```bash
# list vm
microvm -l

# update vm
microvm -u my-microvm


# show logs of a vm
journalctl -u microvm@my-microvm -n 50

# stop vm
systemctl stop microvm@$NAME

# remove vm
rm -rf /var/lib/microvms/$NAME

# Run a MicroVM in foreground(for testing)
# You have to stop the vm before running this command!
microvm -r my-microvm

# Stop a MicroVM that is running in foreground
## 1. run `sudo shutdown -h now` in the vm
## 2. run `systemctl stop microvm@my-microvm` in the host
```

## VM's pros compared to container

1. VM has its own kernel, so it can use a fullfeatured kernel or customise the kernel's
   configuration, without affecting the host.
1. VM use a fullfeatured init system, so it can run services like a real machine.
1. VM can use a fullfeatured network stack, so it can run network services like a real machine. it's
   very useful for hosting some network services(such as tailscale, dae, etc).

## FAQ

### 1. enter the vm without ssh

[Enter running machine as systemd service](https://github.com/astro/microvm.nix/issues/123)
