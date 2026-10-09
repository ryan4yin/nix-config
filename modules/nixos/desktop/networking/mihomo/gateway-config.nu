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
  let args = if $policy == null {
    ["-s", ($sources | path expand), "-o", $tmp]
  } else {
    ["-s", ($sources | path expand), "-p", ($policy | path expand), "-o", $tmp]
  }
  nu $gen ...$args

  let gw = (open --raw $tmp
    | from yaml
    | update ipv6 true
    | update allow-lan true
    | update external-controller $"($address):9090"
    | insert tproxy-port 7893
    | insert external-ui "ui"
    | insert external-ui-url $UI_URL
    | update secret "GATEWAY-SECRET-PLACEHOLDER"
    | update tun.stack "mixed"
    | update tun.strict-route false
    | insert tun.route-address ["0.0.0.0/1", "128.0.0.0/1", "::/1", "8000::/1"]
    | update dns.listen ":1053"
    | update dns.ipv6 true)

  let gw = (if $redact {
    # a file-backed provider (localyaml) has no url to hide
    let pp = ($gw.proxy-providers
      | items {|k, v| {
        name: $k,
        conf: (if ($v | columns | any {|c| $c == "url" }) {
          $v | update url "https://xx.xx.xx.xx"
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
}
