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
      (plain "window-rule" [
        (leaf "match" { app-id = "foot"; })
        (leaf "open-on-workspace" "1terminal")
        (leaf "open-maximized" true)
      ])

      (plain "window-rule" [
        (leaf "match" { app-id = "Alacritty"; })
        (leaf "open-on-workspace" "1terminal")
        (leaf "open-maximized" true)
      ])

      (plain "window-rule" [
        (leaf "match" { app-id = "com.mitchellh.ghostty"; })
        (leaf "open-on-workspace" "1terminal")
        (leaf "open-maximized" true)
      ])

      # --------------- Browser ---------------

      (plain "window-rule" [
        (leaf "match" { app-id = "firefox"; })
        (leaf "open-on-workspace" "2browser")
        (leaf "open-maximized" true)
      ])
      (plain "window-rule" [
        (leaf "match" { app-id = "google-chrome"; })
        (leaf "open-on-workspace" "2browser")
        (leaf "open-maximized" true)
      ])
      (plain "window-rule" [
        (leaf "match" { app-id = "chromium-browser"; })
        (leaf "open-on-workspace" "2browser")
        (leaf "open-maximized" true)
      ])

      # --------------- Chatting ---------------
      (plain "window-rule" [
        (leaf "match" { app-id = "org.telegram.desktop"; })
        (leaf "open-on-workspace" "3chat")
      ])
      (plain "window-rule" [
        (leaf "match" { app-id = "wechat"; })
        (leaf "open-on-workspace" "3chat")
      ])
      (plain "window-rule" [
        (leaf "match" { app-id = "QQ"; })
        (leaf "open-on-workspace" "3chat")
      ])

      # --------------- Networking ---------------

      (plain "window-rule" [
        (leaf "match" { app-id = "clash-verge"; })
        (leaf "open-on-workspace" "0other")
      ])

      # --------------- Meeting ---------------

      (plain "window-rule" [
        (leaf "match" { app-id = "Zoom Workplace"; })
        (leaf "open-on-workspace" "0other")
      ])
    ];
}
