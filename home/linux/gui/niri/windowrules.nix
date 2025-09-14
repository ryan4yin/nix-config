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

      # --------------- 1Terminal ---------------
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

      # --------------- 2Browser ---------------

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

      # --------------- 3Chatting ---------------
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

      # --------------- 4Gaming ---------------

      (plain "window-rule" [
        (leaf "match" { app-id = "steam"; })
        (leaf "open-on-workspace" "4gaming")
      ])
      (plain "window-rule" [
        (leaf "match" { app-id = "steam_app_default"; })
        (leaf "open-on-workspace" "4gaming")
      ])
      (plain "window-rule" [
        (leaf "match" { app-id = "heroic"; })
        (leaf "open-on-workspace" "4gaming")
      ])
      (plain "window-rule" [
        (leaf "match" { app-id = "net.lutris.Lutris"; })
        (leaf "open-on-workspace" "4gaming")
      ])
      (plain "window-rule" [
        (leaf "match" { app-id = "com.vysp3r.ProtonPlus"; })
        (leaf "open-on-workspace" "4gaming")
      ])
      (plain "window-rule" [
        # Run anime games on Linux
        (leaf "match" { app-id = "^moe.launcher"; })
        (leaf "open-on-workspace" "4gaming")
      ])
      (plain "window-rule" [
        # All *.exe (Windows APPs)
        (leaf "match" { app-id = "\.exe$"; })
        (leaf "open-on-workspace" "4gaming")
      ])

      # --------------- 6File ---------------
      (plain "window-rule" [
        (leaf "match" { app-id = "com.github.johnfactotum.Foliate"; })
        (leaf "open-on-workspace" "6file")
      ])
      (plain "window-rule" [
        (leaf "match" { app-id = "thunar"; })
        (leaf "open-on-workspace" "6file")
      ])

      # --------------- 0Other ---------------

      (plain "window-rule" [
        (leaf "match" { app-id = "clash-verge"; })
        (leaf "open-on-workspace" "0other")
      ])

      (plain "window-rule" [
        (leaf "match" { app-id = "Zoom Workplace"; })
        (leaf "open-on-workspace" "0other")
      ])
    ];
}
