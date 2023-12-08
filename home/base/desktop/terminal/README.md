# Termianl Emulators

1. kitty: My main terminal emulator.
2. wezterm: My secondary terminal emulator.
3. alacritty: Standby terminal.


## 'xterm-kitty': unknown terminal type when `ssh` into a remote host or `sudo xxx`

> https://sw.kovidgoyal.net/kitty/faq/#i-get-errors-about-the-terminal-being-unknown-or-opening-the-terminal-failing-or-functional-keys-like-arrow-keys-don-t-work

> https://wezfurlong.org/wezterm/config/lua/config/term.html

kitty set `TERM` to `xterm-kitty` by default, and TUI apps like `viu`, `yazi`, `curses` will try to search in the host's [terminfo(terminal capability data base)](https://linux.die.net/man/5/terminfo) for value of `TERM` to determine the capabilities of the terminal.

But when you `ssh` into a remote host, the remote host is very likely to not have `xterm-kitty` in its terminfo, so you will get this error:

```
'xterm-kitty': unknown terminal type
```

Or when you `sudo xxx`, `sudo` won't preserve the `TERM` variable, it will be reset to root's default `TERM` value, which is `xterm` or `xterm-256color` in most linux distributions, so you will get this error:

```
'xterm-256color': unknown terminal type
```

or 

```
Error opening terminal: xterm-kitty.
```

NixOS preserve the `TERMINFO` and `TERMINFO_DIRS` environment variables, for `root` and the `wheel` group: [nixpkgs/nixos/modules/config/terminfo.nix](https://github.com/NixOS/nixpkgs/blob/nixos-23.11/nixos/modules/config/terminfo.nix#L18)

For nix-darwin, take a look at <https://github.com/LnL7/nix-darwin/wiki/Terminfo-issues>

### Solutions

Simplest solution, it will automatically copy over the terminfo files and also magically enable shell integration on the remote machine: 

```
kitten ssh user@host
```

Or if you do not care about kitty's features(such as true color & graphics protocol), you can simply set `TERM` to `xterm-256color`, which is built-in in most linux distributions:

```
export TERM=xterm-256color
```

If you need kitty's features, but do not like the magic of `kitten`, you can manually install kitty's terminfo on the remote host:

```bash
# install on ubuntu / debian
sudo apt-get install kitty-terminfo

# or copy from local machine
infocmp -a xterm-kitty | ssh myserver tic -x -o \~/.terminfo /dev/stdin
```

