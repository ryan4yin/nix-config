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

## FAQ

### 1. enter the vm without ssh

[Enter running machine as systemd service](https://github.com/astro/microvm.nix/issues/123)
