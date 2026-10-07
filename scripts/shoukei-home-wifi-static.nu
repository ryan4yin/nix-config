#!/usr/bin/env nu
#
# Pin shoukei's home Wi-Fi profile to a static IPv4.
#
# NetworkManager matches connections by SSID. Run this ONCE, while connected to
# HOME_SSID: the script refuses to run unless the current Wi-Fi network is that
# exact SSID, so it can never pin the wrong network by accident. Every other
# network keeps using DHCP. The change is stored in the profile under
# /etc/NetworkManager/system-connections (preserved by impermanence), so it
# survives reboots and rebuilds -- no need to run it again.
#
#   sudo nu scripts/shoukei-home-wifi-static.nu
#
# See hosts/12kingdoms-shoukei/README.md and WORKAROUNDS.md WA-024/025.

# The home network: 2.4 and 5 GHz are merged into this single SSID, so it is
# the only network this script may touch.
const HOME_SSID = "shadow_light_ryan"
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

def main [] {
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

  # Must be connected to the fixed home SSID right now, nothing else.
  let connected = ($wifi | where { |w| $w.name in $active })
  let current_ssids = (if ($connected | is-empty) { [] } else { $connected | get ssid })
  if ($current_ssids | is-empty) {
    error make { msg: $"not connected to Wi-Fi -- connect to '($HOME_SSID)' first" }
  }
  if (not ($HOME_SSID in $current_ssids)) {
    error make { msg: $"not connected to '($HOME_SSID)'; currently on ($current_ssids | str join ', ')" }
  }

  let profiles = ($wifi | where ssid == $HOME_SSID | get name)
  if ($profiles | is-empty) {
    error make { msg: $"no Wi-Fi profile for SSID '($HOME_SSID)'" }
  }

  print $"pinning '($HOME_SSID)': ($STATIC_ADDR) via ($STATIC_GW), dns ($STATIC_DNS)"
  for p in $profiles {
    print $"  set '($p)'"
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

  print ""
  print "done. check: nmcli -f NAME,ipv4.method,ipv4.addresses connection show; ip -4 addr show wld0"
}
