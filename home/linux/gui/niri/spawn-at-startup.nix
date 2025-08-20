niri: {
  programs.niri.config =
    let
      inherit (niri.lib.kdl)
        node
        plain
        leaf
        flag
        ;
    in
    [
      # Add lines like this to spawn processes at startup.
      # Note that running niri as a session supports xdg-desktop-autostart,
      # which may be more convenient to use.
      # --------------- Terminal ---------------
      (leaf "spawn-at-startup" [ "foot" ])
      (leaf "spawn-at-startup" [ "alacritty" ])
      (leaf "spawn-at-startup" [ "ghostty" ])
      # --------------- Networking ---------------
      (leaf "spawn-at-startup" [ "clash-verge" ])
      # --------------- Browser ---------------
      (leaf "spawn-at-startup" [ "firefox" ])
      (leaf "spawn-at-startup" [ "google-chrome-stable" ])
      (leaf "spawn-at-startup" [ "chromium-browser" ])
      # --------------- Chatting ---------------
      (leaf "spawn-at-startup" [ "Telegram" ])
    ];
}
