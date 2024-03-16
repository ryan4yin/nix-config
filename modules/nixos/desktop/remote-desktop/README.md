# Remote Desktop

1. **X11**: We have `xrdp` & `ssh -x` for remote desktop access, which works well for most use
   cases.
2. **Wayland**: (not tested)
3. `waypipe`: similar to `ssh -X`, transfer wayland data over a ssh connection.
4. [rustdesk](https://github.com/rustdesk/rustdesk): a remote desktop client/server written in rust.
5. confirmed broken currently:
   <https://www.reddit.com/r/rustdesk/comments/1912373/rustdesk_on_hyprland/>
6. [sunshine server](https://github.com/LizardByte/Sunshine) +
   [moonlight client](https://github.com/moonlight-stream): It's designed for game streaming, but it
   can be used for remote desktop as well.
7. broken currently: <https://github.com/LizardByte/Sunshine/pull/1977>
