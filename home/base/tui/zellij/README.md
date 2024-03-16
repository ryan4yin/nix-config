# Zellij - A workspace lives in your terminal

Zellij is a terminal workspace with batteries included. At its core, it is a terminal multiplexer
(similar to tmux and screen), but this is merely its infrastructure layer.

Zellij is very user-friendly and easy to use, with a step-by-step hint system that will help you get
to know the keybindings, which is very like the Neovim or helix.

> By contrast, tmux's key design is counterintuitive, there is no prompt system, and the plug-in
> performance is rubbish. It's really a pain to use. tmux's initial release was in 2007, it's too
> old, I would recommend any users that do not have a experience with multiplexer to use zellij
> instead of tmux.

## Why use zellij as the default terminal environment?

By auto start zellij on shell login, and exit the shell session on zellij exit, we can use zellij as
the default terminal environment.

By this way, We will only use the most basic features of the terminal
emulator(kitty/alacritty/wezterm/...), while most of the functions of terminal are provided by
zellij. Thus we can easily switch to any terminal emulator without losing any key functions, and do
not need to take care of the differences between different terminal emulators.

And Zellij can be used not only locally, but also on any remote server, which is very convenient.
Learn once and use everywhere!

> Yeah, you didn't misread it, zellij is very suitable for not only remotely, but also locally!

Some features such as search/copy/scrollback in different terminal emulators are implemented in
different ways, and has different user experience. For example, Wezterm's default search function is
very basic, and it's not easy to use. Kitty's scrollback search/copy is really tricky to use. As for
some Editor such as Neovim, its integrated terminal is really useful, but zellij is more powerful
and useful than it, and more stable! Zellij overcomes these problems, and provides a unified user
experience for all terminal emulators!

Terminal emulators should only be responsible for displaying characters.

## Passthrough mode(Lock Mode)

`Ctrl + g` lock the outer zellij interface, and all keys will be sent to the focused pane.

It's extremely useful when you want to:

1. Use zellij locally for daily work, and use a remote zellij via ssh to do some work on the remote
   server.
1. To avoid the key conflicts between zellij and the program running in the terminal, such as vim,
   tmux, etc.
