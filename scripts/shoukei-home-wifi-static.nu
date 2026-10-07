#!/usr/bin/env nu
#
# Pin shoukei's home Wi-Fi profile(s) to a static IPv4.
#
# NetworkManager matches connections by SSID. Run this ONCE, while connected to
# the home Wi-Fi: with no arguments it pins the network you are on right now,
# and every other network keeps using DHCP. The change is stored in the profile
# under /etc/NetworkManager/system-connections (preserved by impermanence), so
# it survives reboots and rebuilds -- there is no need to run it again.
#
#   sudo nu scripts/shoukei-home-wifi-static.nu
#   sudo nu scripts/shoukei-home-wifi-static.nu shadow_light_ryan shadow_light_ryan-5G
#
# See hosts/12kingdoms-shoukei/README.md and WORKAROUNDS.md WA-024/025.

const STATIC_ADDR = "192.168.5.108/24"
const STATIC_GW = "192.168.5.1"
const STATIC_DNS = "192.168.5.1"

# Run nmcli and abort the script if it exits non-zero.
def nm [args: list<string>] {
  let r = (^nmcli ...$args | complete)
  if $r.exit_code != 0 {
    error make { msg: $"nmcli ($args | str join ' ') failed: ($r.stderr | str trim)" }
  }
  $r.stdout | str trim
}

def main [...ssids: string] {
  if (^id -u | str trim | into int) != 0 {
    error make { msg: "must run as root -- nmcli edits system connections; try: sudo nu scripts/shoukei-home-wifi-static.nu" }
  }

  let active = (
    ^nmcli -t -f NAME,ACTIVE connection show
    | lines
    | where { |l| ($l | split row ":" | last) == "yes" }
    | each { |l| $l | split row ":" | first }
  )

  # One { name, ssid } record per Wi-Fi connection.
  let wifi = (
    ^nmcli -t -f NAME connection show
    | lines
    | where { |n| ($n | str trim) != "" }
    | each { |name|
        if (nm ["-g" "connection.type" "connection" "show" $name]) == "802-11-wireless" {
          { name: $name, ssid: (nm ["-g" "802-11-wireless.ssid" "connection" "show" $name]) }
        }
      }
    | compact
  )

  # No arguments: pin whatever home network we are connected to right now.
  let on_now = ($wifi | where { |w| $w.name in $active })
  let home_ssids = (if ($ssids | is-empty) {
    if ($on_now | is-empty) { [] } else { $on_now | get ssid }
  } else {
    $ssids
  })

  if ($home_ssids | is-empty) {
    error make { msg: "not connected to Wi-Fi -- pass the home SSID(s) explicitly" }
  }
  print $"pinning: ($home_ssids | str join ', ')"

  for ssid in $home_ssids {
    let matches = ($wifi | where ssid == $ssid)
    let profiles = (if ($matches | is-empty) { [] } else { $matches | get name })
    if ($profiles | is-empty) {
      print --stderr $"warning: no Wi-Fi profile for SSID '($ssid)'; skipping"
      continue
    }

    print $"== ($ssid) =="
    for p in $profiles {
      print $"  set '($p)': ($STATIC_ADDR) via ($STATIC_GW), dns ($STATIC_DNS)"
      nm [
        "connection" "modify" $p
        "ipv4.method" "manual"
        "ipv4.addresses" $STATIC_ADDR
        "ipv4.gateway" $STATIC_GW
        "ipv4.dns" $STATIC_DNS
      ] | ignore
    }

    # Collapse duplicates for the same SSID ("<SSID> 1", WORKAROUNDS.md
    # WA-024/025). Deleting an *active* profile wedges the supplicant, so keep
    # the active one and only ever delete the inactive duplicates.
    if ($profiles | length) > 1 {
      let actives = ($profiles | where { |p| $p in $active })
      let keep = (if ($actives | is-empty) { $profiles | first } else { $actives | first })
      for p in $profiles {
        if $p != $keep {
          print $"  delete duplicate '($p)', keeping '($keep)'"
          nm ["connection" "delete" $p] | ignore
        }
      }
    }

    # Apply without dropping the link (avoids the brcmfmac re-auth/password
    # re-prompt, WA-024/025); fall back to a reconnect only if reapply fails.
    for p in $profiles {
      if $p in $active {
        let dev = (nm ["-g" "GENERAL.DEVICES" "connection" "show" $p])
        if ($dev | is-not-empty) {
          let r = (^nmcli device reapply $dev | complete)
          if $r.exit_code == 0 {
            print $"  applied on ($dev) via reapply, no reconnect"
          } else {
            print $"  reapply failed, reconnecting '($p)'"
            nm ["connection" "up" $p] | ignore
          }
        }
      }
    }
  }

  print ""
  print "done. check: nmcli -f NAME,ipv4.method,ipv4.addresses connection show; ip -4 addr show wld0"
}
