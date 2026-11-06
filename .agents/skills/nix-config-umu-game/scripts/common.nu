# Helpers shared by umu-install.nu and umu-uninstall.nu.
#
# Games only run in the umu sandbox (hardening/nixpaks/umu.nix), which mounts
# ~/Gaming over $HOME: a game installed at ~/Gaming/Games/<name> on the host is
# ~/Games/<name> inside. Everything under ~/Gaming is writable by the games, so
# these scripts, which run on the host, treat it as untrusted: they refuse
# symlinks before writing or deleting there, and never execute a file from it.

# The sandbox home, as seen from the host.
export def gaming-dir [] {
  $nu.home-dir | path join "Gaming"
}

# Where games are installed, as seen from the host.
export def games-dir [] {
  gaming-dir | path join "Games"
}

export def reject-symlink [path: string, label: string] {
  let kind = (try { $path | path type } catch { "missing" })
  if $kind == "symlink" {
    print --stderr $"error: ($label) must not be a symlink: ($path)"
    exit 2
  }
}

# Both roots must be real directories before anything below them is touched.
export def reject-symlinked-roots [] {
  reject-symlink (gaming-dir) "Gaming directory"
  reject-symlink (games-dir) "Games directory"
}

export def check-name [name: string] {
  if not ($name =~ '^[a-z0-9]+(-[a-z0-9]+)*$') {
    print --stderr "error: name must be a lowercase slug (letters, digits, hyphens)"
    exit 2
  }
}

# The path as the sandbox sees it, or null if the sandbox cannot see it:
# ~/Gaming becomes $HOME, and the Nix store is read-only. Symlinks stay
# unresolved: under ~/Gaming the games choose their targets.
export def sandbox-path [path: string] {
  let full = ($path | path expand --no-symlink)
  let store = ($env.NIX_STORE_DIR? | default "/nix/store")
  let gaming = (gaming-dir)
  if $full == $gaming or ($full | str starts-with $"($gaming)/") {
    $full | str replace $gaming $nu.home-dir
  } else if ($full | str starts-with $"($store)/") {
    $full
  } else {
    null
  }
}
