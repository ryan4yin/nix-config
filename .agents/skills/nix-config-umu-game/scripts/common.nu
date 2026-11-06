# Helpers shared by umu-install.nu and umu-uninstall.nu.
#
# Everything under ~/Games is writable by the sandboxed games, so these
# scripts, which run on the host, treat it as untrusted: they refuse symlinks
# before writing or deleting there, and never execute a file from it.

export def games-dir [] {
  $nu.home-dir | path join "Games"
}

export def reject-symlink [path: string, label: string] {
  let kind = (try { $path | path type } catch { "missing" })
  if $kind == "symlink" {
    print --stderr $"error: ($label) must not be a symlink: ($path)"
    exit 2
  }
}

# A game name is one lowercase slug. "home" is the sandbox home directory.
export def check-name [name: string] {
  if not ($name =~ '^[a-z0-9]+(-[a-z0-9]+)*$') {
    print --stderr "error: name must be a lowercase slug (letters, digits, hyphens)"
    exit 2
  }
  if $name == "home" {
    print --stderr "error: ~/Games/home is the umu sandbox home; pick another name"
    exit 2
  }
}

# The path as the umu sandbox (hardening/nixpaks/umu.nix) sees it, or null if
# the sandbox cannot see it: ~/Games/home is mounted over $HOME, the rest of
# ~/Games keeps its path, and the Nix store is read-only.
export def sandbox-path [path: string] {
  let full = ($path | path expand)
  let store = ($env.NIX_STORE_DIR? | default "/nix/store")
  let games = (games-dir)
  let home = ($games | path join "home")
  if $full == $home or ($full | str starts-with $"($home)/") {
    $full | str replace $home $nu.home-dir
  } else if ($full | str starts-with $"($games)/") or ($full | str starts-with $"($store)/") {
    $full
  } else {
    null
  }
}
