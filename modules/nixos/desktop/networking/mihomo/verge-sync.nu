#!/usr/bin/env nu
# Render the mihomo config for Clash Verge Rev on macOS and install it as a
# local profile:
#
#   nu verge-sync.nu [--dry-run] [--no-restart] [--sources path] [--verge-dir path]
#                    [--core path] [--name string]
#
# sources.yaml comes from the encrypted dotfiles sync (nix-secrets, `just
# restore`). The profile keeps providers, groups, rules, rule-providers and the
# dns section (per-profile DNS override enabled); Verge-owned sections (ports,
# TUN, controller, geodata) are dropped. tun.route-exclude-address goes into
# verge.yaml's tun_config (TUN is global), dns_config.yaml gets the same
# fake-ip table, and Merge.yaml pins top-level ipv6 for subscription profiles.
# The core validates the profile before anything is installed.
# ---------------------------------------------------------------------------

const profile_uid = "mihomoSyncV1"
const profile_name = "mihomo (nix-config)"

# Verge regenerates these from its GUI settings; a profile carrying them would
# fight the panel. `dns` is deliberately NOT here: Verge 2.5+ has a per-profile
# DNS override (profile_dns_settings), so the generated dns travels with the
# profile. `tun` stays stripped: TUN is global, its exclusions go into
# verge.yaml's tun_config.
const verge_managed = [
  "mixed-port"
  "port"
  "socks-port"
  "redir-port"
  "tproxy-port"
  "allow-lan"
  "log-level"
  "mode"
  "external-controller"
  "external-controller-unix"
  "external-controller-cors"
  "secret"
  "profile"
  "tun"
  "geodata-mode"
  "geo-auto-update"
  "geo-update-interval"
  "geox-url"
]

def fail [msg: string] {
  error make { msg: $msg }
}

def verge-running [] {
  (pgrep -x clash-verge | lines | length) > 0
}

def main [
  --dry-run          # generate and validate, install nothing
  --no-restart       # edit the profile files but leave Verge stopped/running as it is
  --sources: path = "~/.config/mihomo/sources.yaml"
  --verge-dir: path  # defaults to the Clash Verge Rev app-support directory
  --core: path       # defaults to the core inside the Clash Verge.app bundle
  --name: string     # profile name shown in the Verge UI
] {
  let mod = $env.FILE_PWD
  let src = ($sources | path expand)
  if not ($src | path exists) {
    fail $"sources file not found: ($src) -- run 'just restore' in ~/codes/nix-secrets first"
  }
  let vdir = (
    if $verge_dir == null {
      [$env.HOME "Library" "Application Support" "io.github.clash-verge-rev.clash-verge-rev"] | path join
    } else {
      $verge_dir | path expand
    }
  )
  if not ($vdir | path exists) {
    fail $"clash verge directory not found: ($vdir)"
  }
  let core = (
    if $core == null { "/Applications/Clash Verge.app/Contents/MacOS/verge-mihomo" } else { $core }
  ) | path expand
  if not ($core | path exists) {
    fail $"verge core not found: ($core)"
  }
  let name = ($name | default $profile_name)

  # 1. generate the full config with the repo's generator and policy, staged in
  #    the system temp dir so a failed run never touches the Verge directory.
  let tmp = ($env.TMPDIR? | default "/tmp" | path join "mihomo-verge")
  mkdir $tmp
  let staged = ($tmp | path join "generated.yaml")
  let gen = (
    ^nu ($mod | path join "generate.nu")
      -s $src
      -o $staged
      -p ($mod | path join "policy.yaml")
      | complete
  )
  print ($gen.stdout | str trim)
  if ($gen.stderr | str trim) != "" {
    print --stderr ($gen.stderr | str trim)
  }
  if $gen.exit_code != 0 {
    fail $"generate.nu failed (staged in ($staged))"
  }

  # 2. drop the Verge-managed sections. dns travels in the profile and replaces
  #    the global panel for it: sources.yaml + policy.yaml are the single source
  #    of truth; missing entries are a sources.yaml fix, not a per-machine patch.
  let doc = (open $staged)
  let present = ($doc | columns | where { |c| $c in $verge_managed })
  let profile_doc = ($doc | reject ...$present)
  let stripped = ($tmp | path join "profile.yaml")
  $profile_doc | to yaml | save --force $stripped
  ^chmod 600 $stripped
  print $"dropped Verge-managed sections: ($present | str join ', ')"
  print $"dns.fake-ip-filter: ($profile_doc | get dns.fake-ip-filter | length) entries, replacing the global panel for this profile"

  # 3. validate with the core Verge runs; -d resolves provider paths and
  #    geodata exactly as at runtime.
  let check = (^$core -t -d $vdir -f $stripped | complete)
  if $check.exit_code != 0 {
    print --stderr ($check.stderr | str trim)
    fail $"core rejected the profile (staged in ($stripped))"
  }
  print "validated by verge-mihomo -t"

  let target = ($vdir | path join "profiles" $"($profile_uid).yaml")
  let pfile = ($vdir | path join "profiles.yaml")
  let vfile = ($vdir | path join "verge.yaml")
  let gen_excl = ($doc | get -o tun.route-exclude-address | default [])
  if $dry_run {
    print $"dry run: would install ($target) and upsert ($profile_uid) in ($pfile)"
    print $"dry run: would enable profile_dns_settings.($profile_uid) and merge ($gen_excl | length) tun.route-exclude-address entries into ($vfile)"
    print $"dry run: would replace fake-ip-filter/ranges/ipv6 in ($vdir | path join 'dns_config.yaml')"
    print $"dry run: would pin ipv6: true in ($vdir | path join 'profiles' 'Merge.yaml') if absent"
    return
  }

  # 4. Verge rewrites profiles.yaml and verge.yaml while it runs, so quit
  #    first, edit, restart.
  let was_running = (verge-running)
  if $was_running and (not $no_restart) {
    ^osascript -e 'tell application "Clash Verge" to quit' | ignore
    mut waited = 0
    while ($waited < 10) and (verge-running) {
      sleep 1sec
      $waited = ($waited + 1)
    }
    if (verge-running) {
      fail "Clash Verge did not quit within 10s -- nothing installed"
    }
  }

  ^cp $pfile $"($pfile).bak"
  ^cp $vfile $"($vfile).bak"
  $stripped | open | to yaml | save --force $target
  ^chmod 600 $target

  let pconf = (open $pfile)
  let items = ($pconf | get -o items | default [])
  let entry = {
    uid: $profile_uid
    type: "local"
    name: $name
    file: $"($profile_uid).yaml"
    updated: ((date now | into int) / 1000000000 | into int)
  }
  let new_items = (
    if ($items | any { |it| ($it | get -o uid) == $profile_uid }) {
      $items | each { |it| if ($it | get -o uid) == $profile_uid { $entry } else { $it } }
    } else {
      $items ++ [$entry]
    }
  )
  $pconf | upsert items $new_items | to yaml | save --force $pfile
  print $"installed ($target) -- backups: ($pfile).bak, ($vfile).bak"

  # 5. verge.yaml: the per-profile DNS override and the TUN exclusions (TUN is
  #    global). When tun_config is absent, seed stack/mtu/dns-hijack from the
  #    live runtime config.yaml.
  let vconf = (open $vfile)
  let vconf = ($vconf | upsert profile_dns_settings (
    ($vconf | get -o profile_dns_settings | default {}) | upsert $profile_uid { enabled: true }
  ))
  let cur_tun = ($vconf | get -o tun_config | default {})
  let tun = ($cur_tun | upsert route_exclude_address (
    (($cur_tun | get -o route_exclude_address | default []) ++ $gen_excl | uniq)
  ))
  let tun = (
    if ($vconf | get -o tun_config) == null {
      let rt = (open ($vdir | path join "config.yaml") | get -o tun | default {})
      $tun
      | upsert enable true
      | upsert stack ($rt | get -o stack | default "system")
      | upsert mtu ($rt | get -o mtu | default 1500)
      | upsert dns_hijack ($rt | get -o dns-hijack | default ["any:53"])
      | upsert strict_route ($rt | get -o strict-route | default false)
    } else {
      $tun
    }
  )
  $vconf | upsert tun_config $tun | to yaml | save --force $vfile
  print $"enabled profile_dns_settings.($profile_uid); tun_config.route_exclude_address: ($tun | get route_exclude_address | length) entries"

  # 6. dns_config.yaml: the global panel serves every profile without an
  #    override, so its fake-ip table and ipv6 follow the generated config --
  #    replace, not merge.
  let dfile = ($vdir | path join "dns_config.yaml")
  if ($dfile | path exists) {
    ^cp $dfile $"($dfile).bak"
    let gen_dns = ($doc | get -o dns | default {})
    let dconf = (open $dfile)
    let dconf = ($dconf
      | upsert dns.fake-ip-filter ($gen_dns | get -o fake-ip-filter | default [])
      | upsert dns.fake-ip-range ($gen_dns | get -o fake-ip-range | default "198.18.0.1/16")
      | upsert dns.fake-ip-range6 ($gen_dns | get -o fake-ip-range6 | default "2001:2::1/64")
      | upsert dns.ipv6 ($gen_dns | get -o ipv6 | default true)
    )
    $dconf | to yaml | save --force $dfile
    print $"global dns_config.yaml: fake-ip-filter ($gen_dns | get fake-ip-filter | length) entries, fake-ip-range6 ($gen_dns | get fake-ip-range6), ipv6 ($gen_dns | get ipv6)"
  }

  # 7. Merge.yaml: subscription profiles set no top-level ipv6 and Verge's base
  #    config hardcodes false, while step 6 hands every panel profile fake
  #    AAAAs -- fake v6 answers on a core that refuses v6 dials is the
  #    clash-verge-rev#1762 failure. Pin ipv6 true (line must have working v6,
  #    see README). Appended as text to keep the user's comments; skipped when
  #    the key is already set.
  let mfile = ($vdir | path join "profiles" "Merge.yaml")
  if ($mfile | path exists) {
    if (open $mfile | get -o ipv6) == null {
      ^cp $mfile $"($mfile).bak"
      "\n# Synced by verge-sync.nu: the panel hands out fake AAAAs, so every\n# profile needs top-level ipv6 (README: only on a line whose IPv6 works).\nipv6: true\n" | save --append $mfile
      print $"pinned ipv6: true in ($mfile)"
    } else {
      print $"ipv6 already set in ($mfile), left alone"
    }
  }

  if $was_running and (not $no_restart) {
    ^open -a "Clash Verge"
    print "restarted Clash Verge -- select the profile in its UI"
  } else {
    print "select the profile in the Verge UI after (re)starting it"
  }
}
