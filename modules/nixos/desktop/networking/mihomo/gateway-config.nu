#!/usr/bin/env nu
# Render the gateway config (suzi, /etc/mihomo/config.yaml) from the same sources
# as the desktop config: generate.nu's output plus the keys a gateway needs. The
# gateway is not a host in this flake, so this script is the only place its shape
# lives. Never commit the output -- it carries the subscriptions and the private
# domains. `secret` stays a placeholder; the deploy fills it in on the box.
#
#   nu gateway-config.nu [-o gateway.yaml] [--address 192.168.5.178]
#   scp gateway.yaml root@<gateway>:/tmp/   # fill the secret in on the box, -t, restart
# ---------------------------------------------------------------------------

const UI_URL = "https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip"

def main [
  --out (-o): path = "/tmp/gateway.yaml"
  --sources (-s): path = "~/.config/mihomo/sources.yaml"
  --policy (-p): path
  --address (-a): string = "192.168.5.178"
] {
  let out = ($out | path expand)
  let tmp = ($out + ".base")

  let gen = ($env.FILE_PWD | path join "generate.nu")
  let args = if $policy == null {
    ["-s", ($sources | path expand), "-o", $tmp]
  } else {
    ["-s", ($sources | path expand), "-p", ($policy | path expand), "-o", $tmp]
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
    # The gateway uses nftables TProxy for LAN traffic; its desktop-style TUN
    # auto-route would capture the gateway's own DIRECT IPv6 dials again.
    | upsert tun.enable false
    | upsert tun.auto-route false
    | update tun.strict-route false
    # LAN IPv6 transparent handling is unreliable on the gateway; keep client
    # DNS on fake IPv4 so LAN traffic uses the working IPv4 TProxy path.
    | upsert dns.ipv6 false
    | upsert dns.enhanced-mode "fake-ip"
    # the desktop's resolver is loopback; a gateway serves the LAN instead
    | update dns.listen ":1053"
    # LAN clients that use DoH dial the IPs they resolved; sniff so the node dials a name
    | insert sniffer {
        enable: true,
        "parse-pure-ip": true,
        sniff: { TLS: { ports: [443] }, HTTP: { ports: [80] }, QUIC: { ports: [443] } }
      })

  $gw | to yaml | save -f $out
  rm $tmp
  print $"gateway config -> ($out)"
}
