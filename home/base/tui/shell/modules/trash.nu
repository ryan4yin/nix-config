# Move files or directories into the user's home trash can.
#
# Implements the "failsafe" mode from the Freedesktop.org Trash Specification
# (v1.0): every target is moved to $XDG_DATA_HOME/Trash (default
# ~/.local/share/Trash) regardless of the filesystem it lives on, with a
# matching .trashinfo entry so file managers (Thunar, Nautilus, ...) can list
# and restore the items.
#
# On systems where $HOME is on a different filesystem than the user data
# (e.g. a NixOS tmpfs root with persistent dirs bind-mounted in), the
# spec's default per-volume .Trash-$uid mode scatters the trash across
# mount points that file managers never show; this keeps it in one place.

export def main [
  ...targets: string,
] {
  let home = $env.HOME
  let trash = $home | path join .local share Trash
  let files = $trash | path join files
  let info = $trash | path join info
  mkdir $files $info

  mut failed = false
  for target in $targets {
    if $target == "" {
      continue
    }
    let src = $target | path expand
    if $src == "/" or $src == $home {
      $"trash: refusing to move '($src)' to the trash" | print -err
      $failed = true
      continue
    }
    if not ($src | path exists) {
      $"trash: cannot remove '($src)': No such file or directory" | print -err
      $failed = true
      continue
    }

    if not (trash-one $src $files $info) {
      $failed = true
    }
  }

  if $failed {
    error make {
      msg: "one or more targets could not be moved to the trash"
    }
  }
}

# Move a single source into the trash; returns true on success.
def trash-one [
  src: string,
  files: string,
  info: string,
] {
  # find a name that is not yet taken in the trash
  let base = $src | path basename
  mut name = $base
  mut n = 0
  while ($files | path join $name | path exists) {
    $n = $n + 1
    $name = $"($base)-($n)"
  }

  let dest = $files | path join $name
  let info_file = $info | path join $"($name).trashinfo"
  let date = (date now) | format date "%Y-%m-%dT%H:%M:%S"
  $"[Trash Info]\nPath=(trash-encode-path $src)\nDeletionDate=($date)" | save $info_file

  try {
    mv $src $dest
    true
  } catch {
    rm $info_file
    $"trash: failed to move '($src)' into the trash" | print -err
    false
  }
}

# Percent-encode a path for the Path= entry of a .trashinfo file.
# Unreserved characters (RFC 3986) and "/" are kept as-is, everything else
# becomes %XX per UTF-8 byte, e.g. "/a b/测.txt" -> "/a%20b/%E6%B5%8B.txt".
def trash-encode-path [p: string] {
  $p
  | split chars
  | each { |c|
    # uppercase hex, two digits per UTF-8 byte: "/" -> "2F", "测" -> "E6B58B"
    let hex = $c | into binary | encode hex
    if ($hex | str length) == 2 {
      if (trash-is-unreserved $hex) {
        $c
      } else {
        $"%($hex)"
      }
    } else {
      let len = $hex | str length
      mut i = 0
      mut out = ""
      while $i < $len {
        $out = $"($out)%($hex | str substring $i..($i + 1))"
        $i = $i + 2
      }
      $out
    }
  }
  | str join
}

# unreserved per RFC 3986, plus "/": - . / 0-9 A-Z _ ~
def trash-is-unreserved [h: string] {
  (
    $h == "2D"
    or $h == "2E"
    or $h == "2F"
    or $h == "5F"
    or $h == "7E"
    or ($h >= "30" and $h <= "39") # 0-9
    or ($h >= "41" and $h <= "5A") # A-Z
    or ($h >= "61" and $h <= "7A") # a-z
  )
}

export def help [] {
  print -n (main -h)

  print (
  [
    $"(ansi green)Examples(ansi reset):"
    $"  > (ansi light_green)trash report.pdf(ansi reset)"
    $"  > (ansi light_green)trash ~/projects/old-api 'my docs/broken thing'(ansi reset)"
  ] |
  str join "\n" |
  nu-highlight
  )
}
