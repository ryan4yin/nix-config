#!/usr/bin/env nu
# Render the gateway config (suzi, /etc/mihomo/config.yaml) from the same sources
# as the desktop config: generate.nu's output plus the keys a gateway needs. The
# gateway is not a host in this flake, so this script is the only place its shape
# lives. Never commit the output -- it carries the subscriptions and the private
# domains. `secret` stays a placeholder; the deploy fills it in on the box.
#
#   nu gateway-config.nu [-o gateway.yaml] [--address 192.168.5.178] [--redact]
#   scp gateway.yaml root@<gateway>:/tmp/   # fill the secret in on the box, -t, restart
# ---------------------------------------------------------------------------

const UI_URL = "https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip"

def main [
  --out (-o): path = "/tmp/gateway.yaml"
  --sources (-s): path = "~/.config/mihomo/sources.yaml"
  --policy (-p): path
  --address (-a): string = "192.168.5.178"
  --redact # replace the secret and the subscription URLs: what a shareable template needs
] {
  let out = ($out | path expand)
  let tmp = ($out + ".base")

  let gen = ($env.FILE_PWD | path join "generate.nu")
  # the gateway has no profiles dir: its config carries the nodes, as before
  let args = if $policy == null {
    ["-s", ($sources | path expand), "-o", $tmp, "--inline-file-providers"]
  } else {
    ["-s", ($sources | path expand), "-p", ($policy | path expand), "-o", $tmp, "--inline-file-providers"]
  }
  nu $gen ...$args

  let gw = (open --raw $tmp
    | from yaml
    | update allow-lan true
    | update external-controller $"($address):9090"
    | insert tproxy-port 7893
    | insert external-ui "ui"
    | insert external-ui-url $UI_URL
    | update secret "GATEWAY-SECRET-PLACEHOLDER"
    # the base leaves the stack at upstream's default; this box has run the kernel stack for months
    | upsert tun.stack "mixed"
    | update tun.strict-route false
    # the desktop's resolver is loopback; a gateway serves the LAN instead
    | update dns.listen ":1053"
    # LAN clients that use DoH dial the IPs they resolved; sniff so the node dials a name
    | insert sniffer {
        enable: true,
        "parse-pure-ip": true,
        sniff: { TLS: { ports: [443] }, HTTP: { ports: [80] }, QUIC: { ports: [443] } }
      })

  let gw = (if $redact {
    # The template is meant to be shared, so hide the subscription urls and empty
    # any inline provider payload: the payload is the node uuids and keys.
    let pp = ($gw.proxy-providers
      | items {|k, v| {
        name: $k,
        conf: (if ($v | columns | any {|c| $c == "url" }) {
          $v | update url "https://xx.xx.xx.xx"
        } else if ($v | columns | any {|c| $c == "payload" }) {
          $v | update payload []
        } else {
          $v
        })
      } })
    $gw
    | update secret "NOTE-PLEASE-CHANGE-ME"
    | update proxy-providers ($pp | reduce -f {} {|it, acc| $acc | insert $it.name $it.conf })
  } else {
    $gw
  })

  $gw | to yaml | save -f $out
  rm $tmp
  print $"gateway config -> ($out)"
  if $redact {
    print "  redacted: urls replaced and inline provider payloads emptied -- paste nodes back before use"
  }
}
