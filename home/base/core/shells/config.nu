# Nushell Config File Documentation
#
# Warning: This file is intended for documentation purposes only and
# is not intended to be used as an actual configuration file as-is.
#
# version = "0.103.0"
#
# A `config.nu` file is used to override default Nushell settings,
# define (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings, so
# the user's `config.nu` only needs to override these defaults if
# desired.
#
# This file serves as simple "in-shell" documentation for these
# settings, or you can view a more complete discussion online at:
# https://nushell.sh/book/configuration
#
# You can pretty-print and page this file using:
# config nu --doc | nu-highlight | less -R

# $env.config
# -----------
# The $env.config environment variable is a record containing most Nushell
# configuration settings. Keep in mind that, as a record, setting it to a
# new record will remove any keys which aren't in the new record. Nushell
# will then automatically merge in the internal defaults for missing keys.
#
# The same holds true for keys in the $env.config which are also records
# or lists.
#
# For this reason, settings are typically changed by updating the value of
# a particular key. Merging a new config record is also possible. See the
# Configuration chapter of the book for more information.


$env.config.history.file_format = "sqlite"
$env.config.history.max_size = 5_000_000

# isolation (bool):
# `true`: New history from other currently-open Nushell sessions is not
# seen when scrolling through the history using PrevHistory (typically
# the Up key) or NextHistory (Down key)
# `false`: All commands entered in other Nushell sessions will be mixed with
# those from the current shell.
# Note: Older history items (from before the current shell was started) are
# always shown.
# This setting only applies to SQLite-backed history
$env.config.history.isolation = true

# ----------------------
# Miscellaneous Settings
# ----------------------

# show_banner (bool): Enable or disable the welcome banner at startup
$env.config.show_banner = false

# rm.always_trash (bool):
# true: rm behaves as if the --trash/-t option is specified
# false: rm behaves as if the --permanent/-p option is specified (default)
$env.config.rm.always_trash = true

# recursion_limit (int): how many times a command can call itself recursively
# before an error will be generated.
$env.config.recursion_limit = 50

# ---------------------------
# Commandline Editor Settings
# ---------------------------

# edit_mode (string) "vi" or "emacs" sets the editing behavior of Reedline
$env.config.edit_mode = "vi"

# Command that will be used to edit the current line buffer with Ctrl+O.
# If unset, uses $env.VISUAL and then $env.EDITOR
#
$env.config.buffer_editor = ["nvim", "--clean"]

# cursor_shape_* (string)
# -----------------------
# The following variables accept a string from the following selections:
# "block", "underscore", "line", "blink_block", "blink_underscore", "blink_line", or "inherit"
# "inherit" skips setting cursor shape and uses the current terminal setting.
$env.config.cursor_shape.emacs = "inherit"         # Cursor shape in emacs mode
$env.config.cursor_shape.vi_insert = "block"       # Cursor shape in vi-insert mode
$env.config.cursor_shape.vi_normal = "underscore"  # Cursor shape in normal vi mode

# --------------------
# Terminal Integration
# --------------------
# Nushell can output a number of escape codes to enable advanced features in Terminal Emulators
# that support them. Settings in this section enable or disable these features in Nushell.
# Features aren't supported by your Terminal can be disabled. Features can also be disabled,
#  of course, if there is a conflict between the Nushell and Terminal's implementation.

# use_kitty_protocol (bool):
# A keyboard enhancement protocol supported by the Kitty Terminal. Additional keybindings are
# available when using this protocol in a supported terminal. For example, without this protocol,
# Ctrl+I is interpreted as the Tab Key. With this protocol, Ctrl+I and Tab can be mapped separately.
$env.config.use_kitty_protocol = false

# osc2 (bool):
# When true, the current directory and running command are shown in the terminal tab/window title.
# Also abbreviates the directory name by prepending ~ to the home directory and its subdirectories.
$env.config.shell_integration.osc2 = true

# osc7 (bool):
# Nushell will report the current directory to the terminal using OSC 7. This is useful when
# spawning new tabs in the same directory.
$env.config.shell_integration.osc7 = true

# osc9_9 (bool):
# Enables/Disables OSC 9;9 support, originally a ConEmu terminal feature. This is an
# alternative to OSC 7 which also communicates the current path to the terminal.
$env.config.shell_integration.osc9_9 = false

# osc8 (bool):
# When true, the `ls` command will generate clickable links that can be launched in another
# application by the terminal.
# Note: This setting replaces the now deprecated `ls.clickable_links`
$env.config.shell_integration.osc8 = true

# osc133 (bool):
# true/false to enable/disable OSC 133 support, a set of several escape sequences which
# report the (1) starting location of the prompt, (2) ending location of the prompt,
# (3) starting location of the command output, and (4) the exit code of the command.

# originating with Final Term. These sequences report information regarding the prompt
# location as well as command status to the terminal. This enables advanced features in
# some terminals, including the ability to provide separate background colors for the
# command vs. the output, collapsible output, or keybindings to scroll between prompts.
$env.config.shell_integration.osc133 = true

# osc633 (bool):
# true/false to enable/disable OSC 633, an extension to OSC 133 for Visual Studio Code
$env.config.shell_integration.osc633 = true

# NU_LIB_DIRS
# -----------
# Directories in this constant are searched by the
# `use` and `source` commands.
#
# By default, the `scripts` subdirectory of the default configuration
# directory is included:
const NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
    ($nu.data-dir | path join 'completions') # default home for nushell completions
]

# NU_PLUGIN_DIRS
# --------------
# Directories to search for plugin binaries when calling add.

# By default, the `plugins` subdirectory of the default configuration
# directory is included:
const NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

# As with NU_LIB_DIRS, an $env.NU_PLUGIN_DIRS is searched after the constant version

# The `path add` function from the Standard Library also provides
# a convenience method for prepending to the path:
use std/util "path add"
path add "~/.local/bin"

# You can remove duplicate directories from the path using:
$env.PATH = ($env.PATH | uniq)

