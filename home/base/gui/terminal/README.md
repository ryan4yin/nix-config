# Terminal Emulators

I used to spend a lot of time on terminal emulators, to make them match my taste, but now I found
that it's not worth it, **Zellij can provide a user-friendly and unified user experience for all
terminal emulators! without any pain**!

Currently, I only use the most basic features of terminal emulators, such as true color, graphics
protocol, etc. Other features such as tabs, scrollback buffer, select/search/copy, etc, are all
provided by zellij!

My current terminal emulators are:

1. kitty: My main terminal emulator.
   1. to select/copy a large mount of text, We should do some tricks via kitty's `scrollback_pager`
      with neovim, it's really painful: <https://github.com/kovidgoyal/kitty/issues/719>
2. foot: A fast, lightweight and minimalistic Wayland terminal emulator.
   1. foot only do the things a terminal emulator should do, no more, no less.
   1. It's really suitable for tiling window manager or zellij users!
3. alacritty: A cross-platform, GPU-accelerated terminal emulator.
   1. alacritty is really fast, I use it as a backup terminal emulator on all my desktops.

## 'xterm-kitty': unknown terminal type when `ssh` into a remote host or `sudo xxx`

> https://sw.kovidgoyal.net/kitty/faq/#i-get-errors-about-the-terminal-being-unknown-or-opening-the-terminal-failing-or-functional-keys-like-arrow-keys-don-t-work

> https://wezfurlong.org/wezterm/config/lua/config/term.html

kitty set `TERM` to `xterm-kitty` by default, and TUI apps like `viu`, `yazi`, `curses` will try to
search in the host's [terminfo(terminal capability data base)](https://linux.die.net/man/5/terminfo)
for value of `TERM` to determine the capabilities of the terminal.

But when you `ssh` into a remote host, the remote host is very likely to not have `xterm-kitty` in
its terminfo, so you will get this error:

```
'xterm-kitty': unknown terminal type
```

Or when you `sudo xxx`, `sudo` won't preserve the `TERM` variable, it will be reset to root's
default `TERM` value, which is `xterm` or `xterm-256color` in most linux distributions, so you will
get this error:

```
'xterm-256color': unknown terminal type
```

or

```
Error opening terminal: xterm-kitty.
```

NixOS preserve the `TERMINFO` and `TERMINFO_DIRS` environment variables, for `root` and the `wheel`
group:
[nixpkgs/nixos/modules/config/terminfo.nix](https://github.com/NixOS/nixpkgs/blob/nixos-24.11/nixos/modules/config/terminfo.nix#L18)

For nix-darwin, take a look at <https://github.com/LnL7/nix-darwin/wiki/Terminfo-issues>

### Solutions

Simplest solution, it will automatically copy over the terminfo files and also magically enable
shell integration on the remote machine:

```
kitten ssh user@host
```

Or if you do not care about kitty's features(such as true color & graphics protocol), you can simply
set `TERM` to `xterm-256color`, which is built-in in most linux distributions:

```
export TERM=xterm-256color
```

If you need kitty's features, but do not like the magic of `kitten`, you can manually install
kitty's terminfo on the remote host:

```bash
# install on ubuntu / debian
sudo apt-get install kitty-terminfo

# or copy from local machine
infocmp -a xterm-kitty | ssh myserver tic -x -o \~/.terminfo /dev/stdin
```
