# Nushell Config File
#
# version = 0.81.1

# let's define some colors

# https://github.com/catppuccin/i3/blob/main/themes/catppuccin-mocha
let rosewater = "#f5e0dc"
let flamingo  = "#f2cdcd"
let pink      = "#f5c2e7"
let mauve     = "#cba6f7"
let red       = "#f38ba8"
let maroon    = "#eba0ac"
let peach     = "#fab387"
let green     = "#a6e3a1"
let teal      = "#94e2d5"
let sky       = "#89dceb"
let sapphire  = "#74c7ec"
let blue      = "#89b4fa"
let lavender  = "#b4befe"
let text      = "#cdd6f4"
let subtext1  = "#bac2de"
let subtext0  = "#a6adc8"
let overlay2  = "#9399b2"
let overlay1  = "#7f849c"
let overlay0  = "#6c7086"
let surface2  = "#585b70"
let surface1  = "#45475a"
let surface0  = "#313244"
let base      = "#1e1e2e"
let mantle    = "#181825"
let crust     = "#11111b"

# we're creating a theme here that uses the colors we defined above.

let catppuccin_theme = {
    separator: $overlay2
    leading_trailing_space_bg: $surface2
    header: $red
    date: $pink
    filesize: $green
    row_index: $text
    bool: $peach
    int: $red
    duration: $sky
    range: $sapphire
    float: $lavender
    string: $text
    nothing: $overlay1
    binary: $subtext1
    cellpath: $subtext0
    hints: dark_gray

    shape_garbage: { fg: $overlay2 bg: $red attr: b}
    shape_bool: $maroon
    shape_int: { fg: $pink attr: b}
    shape_float: { fg: $pink attr: b}
    shape_range: { fg: $overlay0 attr: b}
    shape_internalcall: { fg: $maroon attr: b}
    shape_external: $mauve
    shape_externalarg: { fg: $red attr: b}
    shape_literal: $flamingo
    shape_operator: $rosewater
    shape_signature: { fg: $red attr: b}
    shape_string: $red
    shape_filepath: $peach
    shape_globpattern: { fg: $teal attr: b}
    shape_variable: $pink
    shape_flag: { fg: $mauve attr: b}
    shape_custom: {attr: b}
}

# The default config record. This is where much of your global configuration is setup.
$env.config = {
  color_config: $catppuccin_theme  # <-- this is the theme
  use_ansi_coloring: true

  # true or false to enable or disable the welcome banner at startup
  show_banner: false
  
  table: {
    mode: rounded # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
    index_mode: always # "always" show indexes, "never" show indexes, "auto" = show indexes when a table has "index" column
    show_empty: true # show 'empty list' and 'empty record' placeholders for command output
    trim: {
      methodology: wrapping # wrapping or truncating
      wrapping_try_keep_words: true # A strategy used by the 'wrapping' methodology
      truncating_suffix: "..." # A suffix used by the 'truncating' methodology
    }
  }

  completions: {
    case_sensitive: false # set to true to enable case-sensitive completions
    quick: true  # set this to false to prevent auto-selecting completions when only one remains
    partial: true  # set this to false to prevent partial filling of the prompt
    algorithm: "prefix"  # prefix or fuzzy
    external: {
      enable: true # set to false to prevent nushell looking into $env.PATH to find more suggestions, `false` recommended for WSL users as this look up may be very slow
      max_results: 100 # setting it lower can improve completion performance at the cost of omitting some options
      completer: null # check 'carapace_completer' above as an example
    }
  }
  filesize: {
    metric: true # true => KB, MB, GB (ISO standard), false => KiB, MiB, GiB (Windows standard)
    format: "auto" # b, kb, kib, mb, mib, gb, gib, tb, tib, pb, pib, eb, eib, zb, zib, auto
  }
  cursor_shape: {
    emacs: line # block, underscore, line, blink_block, blink_underscore, blink_line (line is the default)
    vi_insert: block # block, underscore, line , blink_block, blink_underscore, blink_line (block is the default)
    vi_normal: underscore # block, underscore, line, blink_block, blink_underscore, blink_line (underscore is the default)
  }
  footer_mode: "auto" # always, never, number_of_rows, auto
  float_precision: 2 # the precision for displaying floats in tables
  # buffer_editor: "emacs" # command that will be used to edit the current line buffer with ctrl+o, if unset fallback to $env.EDITOR and $env.VISUAL
  bracketed_paste: true # enable bracketed paste, currently useless on windows
  edit_mode: emacs # emacs, vi
  shell_integration: {
        # osc2 abbreviates the path if in the home_dir, sets the tab/window title, shows the running command in the tab/window title
        osc2: true
        # osc7 is a way to communicate the path to the terminal, this is helpful for spawning new tabs in the same directory
        osc7: true
        # osc8 is also implemented as the deprecated setting ls.show_clickable_links, it shows clickable links in ls output if your terminal supports it. show_clickable_links is deprecated in favor of osc8
        osc8: true
        # osc9_9 is from ConEmu and is starting to get wider support. It's similar to osc7 in that it communicates the path to the terminal
        osc9_9: false
        # osc133 is several escapes invented by Final Term which include the supported ones below.
        # 133;A - Mark prompt start
        # 133;B - Mark prompt end
        # 133;C - Mark pre-execution
        # 133;D;exit - Mark execution finished with exit code
        # This is used to enable terminals to know where the prompt is, the command is, where the command finishes, and where the output of the command is
        osc133: true
        # osc633 is closely related to osc133 but only exists in visual studio code (vscode) and supports their shell integration features
        # 633;A - Mark prompt start
        # 633;B - Mark prompt end
        # 633;C - Mark pre-execution
        # 633;D;exit - Mark execution finished with exit code
        # 633;E - NOT IMPLEMENTED - Explicitly set the command line with an optional nonce
        # 633;P;Cwd=<path> - Mark the current working directory and communicate it to the terminal
        # and also helps with the run recent menu in vscode
        osc633: true
        # reset_application_mode is escape \x1b[?1l and was added to help ssh work better
        reset_application_mode: true
    }
  render_right_prompt_on_last_line: false # true or false to enable or disable right prompt to be rendered on last line of the prompt.
}
