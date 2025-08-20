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
      (plain "input" [
        (plain "keyboard" [
          (plain "xkb" [
            # You can set rules, model, layout, variant and options.
            # For more information, see xkeyboard-config(7).

            # For example:
            # (leaf "layout" "us,ru")
            # (leaf "options" "grp:win_space_toggle,compose:ralt,ctrl:nocaps")
          ])

          # You can set the keyboard repeat parameters. The defaults match wlroots and sway.
          # Delay is in milliseconds before the repeat starts. Rate is in characters per second.
          # (leaf "repeat-delay" 600)
          # (leaf "repeat-rate" 25)

          # Niri can remember the keyboard layout globally (the default) or per-window.
          # - "global" - layout change is global for all windows.
          # - "window" - layout is tracked for each window individually.
          # (leaf "track-layout" "global")
        ])

        # Next sections include libinput settings.
        # Omitting settings disables them, or leaves them at their default values.
        (plain "touchpad" [
          (flag "tap")
          # (flag "dwt")
          # (flag "dwtp")
          (flag "natural-scroll")
          # (leaf "accel-speed" 0.2)
          # (leaf "accel-profile" "flat")
          # (leaf "tap-button-map" "left-middle-right")
        ])

        (plain "mouse" [
          # (flag "natural-scroll")
          # (leaf "accel-speed" 0.2)
          # (leaf "accel-profile" "flat")
        ])

        # By default, niri will take over the power button to make it sleep
        # instead of power off.
        # Uncomment this if you would like to configure the power button elsewhere
        # (i.e. logind.conf).
        # (flag "disable-power-key-handling")
      ])

      (plain "layout" [
        # By default focus ring and border are rendered as a solid background rectangle
        # behind windows. That is, they will show up through semitransparent windows.
        # This is because windows using client-side decorations can have an arbitrary shape.
        #
        # If you don't like that, you should uncomment `prefer-no-csd` below.
        # Niri will draw focus ring and border *around* windows that agree to omit their
        # client-side decorations.

        # You can change how the focus ring looks.
        (plain "focus-ring" [
          # Uncomment this line to disable the focus ring.
          # (flag "off")

          # How many logical pixels the ring extends out from the windows.
          (leaf "width" 4)

          # Colors can be set in a variety of ways:
          # - CSS named colors: "red"
          # - RGB hex: "#rgb", "#rgba", "#rrggbb", "#rrggbbaa"
          # - CSS-like notation: "rgb(255, 127, 0)", rgba(), hsl() and a few others.

          # Color of the ring on the active monitor.
          (leaf "active-color" "#7fc8ff")

          # Color of the ring on inactive monitors.
          (leaf "inactive-color" "#505050")

          # Additionally, there's a legacy RGBA syntax:
          # (leaf "active-color" [ 127 200 255 255 ])

          # You can also use gradients. They take precedence over solid colors.
          # Gradients are rendered the same as CSS linear-gradient(angle, from, to).
          # The angle is the same as in linear-gradient, and is optional,
          # defaulting to 180 (top-to-bottom gradient).
          # You can use any CSS linear-gradient tool on the web to set these up.
          #
          # (leaf "active-gradient" { from="#80c8ff"; to="#bbddff"; angle=45; })

          # You can also color the gradient relative to the entire view
          # of the workspace, rather than relative to just the window itself.
          # To do that, set relative-to="workspace-view";
          #
          # (leaf "inactive-gradient" { from="#505050"; to="#808080"; angle=45; relative-to="workspace-view"; })
        ])

        # You can also add a border. It's similar to the focus ring, but always visible.
        (plain "border" [
          # The settings are the same as for the focus ring.
          # If you enable the border, you probably want to disable the focus ring.
          (flag "off")

          (leaf "width" 4)
          (leaf "active-color" "#ffc87f")
          (leaf "inactive-color" "#505050")

          # (leaf "active-gradient" { from="#ffbb66"; to="#ffc880"; angle=45; relative-to="workspace-view"; })
          # (leaf "inactive-gradient" { from="#505050"; to="#808080"; angle=45; relative-to="workspace-view"; })
        ])

        # You can customize the widths that "switch-preset-column-width" (Mod+R) toggles between.
        (plain "preset-column-widths" [
          # Proportion sets the width as a fraction of the output width, taking gaps into account.
          # For example, you can perfectly fit four windows sized "proportion 0.25" on an output.
          # The default preset widths are 1/3, 1/2 and 2/3 of the output.
          (leaf "proportion" (1.0 / 3.0))
          (leaf "proportion" (1.0 / 2.0))
          (leaf "proportion" (2.0 / 3.0))

          # Fixed sets the width in logical pixels exactly.
          # (leaf "fixed" 1920)
        ])

        # You can change the default width of the new windows.
        (plain "default-column-width" [
          (leaf "proportion" 0.5)
        ])
        # If you leave the children empty, the windows themselves will decide their initial width.
        # (plain "default-column-width" [])

        # Set gaps around windows in logical pixels.
        (leaf "gaps" 8)

        # Struts shrink the area occupied by windows, similarly to layer-shell panels.
        # You can think of them as a kind of outer gaps. They are set in logical pixels.
        # Left and right struts will cause the next window to the side to always be visible.
        # Top and bottom struts will simply add outer gaps in addition to the area occupied by
        # layer-shell panels and regular gaps.
        (plain "struts" [
          # (leaf "left" 64)
          # (leaf "right" 64)
          # (leaf "top" 64)
          # (leaf "bottom" 64)
        ])

        # When to center a column when changing focus, options are:
        # - "never", default behavior, focusing an off-screen column will keep at the left
        #   or right edge of the screen.
        # - "on-overflow", focusing a column will center it if it doesn't fit
        #   together with the previously focused column.
        # - "always", the focused column will always be centered.
        (leaf "center-focused-column" "never")
      ])

      (plain "cursor" [
        # Change the theme and size of the cursor as well as set the
        # `XCURSOR_THEME` and `XCURSOR_SIZE` env variables.
        # (leaf "xcursor-theme" "default")
        # (leaf "xcursor-size" 24)
      ])

      # Uncomment this line to ask the clients to omit their client-side decorations if possible.
      # If the client will specifically ask for CSD, the request will be honored.
      # Additionally, clients will be informed that they are tiled, removing some rounded corners.
      # (flag "prefer-no-csd")

      # You can change the path where screenshots are saved.
      # A ~ at the front will be expanded to the home directory.
      # The path is formatted with strftime(3) to give you the screenshot date and time.
      (leaf "screenshot-path" "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png")

      # You can also set this to null to disable saving screenshots to disk.
      # (leaf "screenshot-path" null)

      # Settings for the "Important Hotkeys" overlay.
      (plain "hotkey-overlay" [
        # Uncomment this line if you don't want to see the hotkey help at niri startup.
        # (flag "skip-at-startup")
      ])

      (plain "layer-rule" [
        (leaf "match" { namespace = "waybar"; })
        (leaf "opacity" 0.8)
      ])

      # Animation settings.
      (plain "animations" [
        # Uncomment to turn off all animations.
        # (flag "off")

        # Slow down all animations by this factor. Values below 1 speed them up instead.
        # (leaf "slowdown" 3.0)

        # You can configure all individual animations.
        # Available settings are the same for all of them.
        # - off disables the animation.
        #
        # Niri supports two animation types: easing and spring.
        # You can set properties for only ONE of them.
        #
        # Easing has the following settings:
        # - duration-ms sets the duration of the animation in milliseconds.
        # - curve sets the easing curve. Currently, available curves
        #   are "ease-out-cubic" and "ease-out-expo".
        #
        # Spring animations work better with touchpad gestures, because they
        # take into account the velocity of your fingers as you release the swipe.
        # The parameters are less obvious and generally should be tuned
        # with trial and error. Notably, you cannot directly set the duration.
        # You can use this app to help visualize how the spring parameters
        # change the animation: https://flathub.org/apps/app.drey.Elastic
        #
        # A spring animation is configured like this:
        # - (leaf "spring" { damping-ratio=1.0; stiffness=1000; epsilon=0.0001; })
        #
        # The damping ratio goes from 0.1 to 10.0 and has the following properties:
        # - below 1.0: underdamped spring, will oscillate in the end.
        # - above 1.0: overdamped spring, won't oscillate.
        # - 1.0: critically damped spring, comes to rest in minimum possible time
        #    without oscillations.
        #
        # However, even with damping ratio = 1.0 the spring animation may oscillate
        # if "launched" with enough velocity from a touchpad swipe.
        #
        # Lower stiffness will result in a slower animation more prone to oscillation.
        #
        # Set epsilon to a lower value if the animation "jumps" in the end.
        #
        # The spring mass is hardcoded to 1.0 and cannot be changed. Instead, change
        # stiffness proportionally. E.g. increasing mass by 2x is the same as
        # decreasing stiffness by 2x.

        # Animation when switching workspaces up and down,
        # including after the touchpad gesture.
        (plain "workspace-switch" [
          # (flag "off")
          # (leaf "spring" { damping-ratio=1.0; stiffness=1000; epsilon=0.0001; })
        ])

        # All horizontal camera view movement:
        # - When a window off-screen is focused and the camera scrolls to it.
        # - When a new window appears off-screen and the camera scrolls to it.
        # - When a window resizes bigger and the camera scrolls to show it in full.
        # - And so on.
        (plain "horizontal-view-movement" [
          # (flag "off")
          # (leaf "spring" { damping-ratio=1.0; stiffness=800; epsilon=0.0001; })
        ])

        # Window opening animation. Note that this one has different defaults.
        (plain "window-open" [
          # (flag "off")
          # (leaf "duration-ms" 150)
          # (leaf "curve" "ease-out-expo")

          # Example for a slightly bouncy window opening:
          # (leaf "spring" { damping-ratio=0.8; stiffness=1000; epsilon=0.0001; })
        ])

        # Config parse error and new default config creation notification
        # open/close animation.
        (plain "config-notification-open-close" [
          # (flag "off")
          # (leaf "spring" { damping-ratio=0.6; stiffness=1000; epsilon=0.001; })
        ])
      ])
    ];
}
