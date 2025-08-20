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
      # ============= Window Rules =============
      # Get all the window's information via:
      #   niri msg windows

      # --------------- Terminal ---------------
      # foot → ws 13
      (plain "window-rule" [
        (leaf "match" { app-id = "foot"; })
        (leaf "open-on-workspace" "1terminal")
        (leaf "open-maximized" true)
      ])

      # Alacritty → ws 10
      (plain "window-rule" [
        (leaf "match" { app-id = "Alacritty"; })
        (leaf "open-on-workspace" "1terminal")
        (leaf "open-maximized" true)
      ])

      # Ghostty → ws 14
      (plain "window-rule" [
        (leaf "match" { app-id = "com.mitchellh.ghostty"; })
        (leaf "open-on-workspace" "1terminal")
        (leaf "open-maximized" true)
      ])

      # --------------- Networking ---------------

      # Clash Verge → ws 7
      (plain "window-rule" [
        (leaf "match" { app-id = "clash-verge"; })
        (leaf "open-on-workspace" "0other")
      ])

      # --------------- Browser ---------------

      # Firefox → ws 11
      (plain "window-rule" [
        (leaf "match" { app-id = "firefox"; })
        (leaf "open-on-workspace" "2browser")
        (leaf "open-maximized" true)
      ])
      # Google Chrome → ws 12
      (plain "window-rule" [
        (leaf "match" { app-id = "google-chrome"; })
        (leaf "open-on-workspace" "2browser")
        (leaf "open-maximized" true)
      ])

      # --------------- Chatting ---------------
      # Telegram → ws 6
      (plain "window-rule" [
        (leaf "match" { app-id = "org.telegram.desktop"; })
        (leaf "open-on-workspace" "3chat")
      ])
    ];
}
