# Mihomo

Native mihomo core with the metacubexd dashboard, replacing the Clash Verge GUI. Enable per host
with `modules.networking.mihomo.enable = true` (`ai`, `shoukei`, and the headless `ruby` / `kana`).

## Usage

```sh
cp sources.example.yaml ~/.config/mihomo/sources.yaml && chmod 600 ~/.config/mihomo/sources.yaml
$EDITOR ~/.config/mihomo/sources.yaml           # fill in: secret, private_domains, providers
nu generate.nu                                  # -> ~/.config/mihomo/config.yaml, mode 0600
mihomo -t -f ~/.config/mihomo/config.yaml       # validate before restarting
sudo systemctl restart mihomo.service           # dashboard: http://127.0.0.1:9090/ui
```

`sources.yaml` is the only file you edit and the only one holding anything private: subscription
URLs, the dashboard secret, private domain names. It stays out of the repository and out of the Nix
store; the module loads `config.yaml` through systemd `LoadCredential`. Generate the config before
enabling the module on a new host, otherwise the service will not start.

## Files

| File                   | Role                                                          |
| ---------------------- | ------------------------------------------------------------- |
| `default.nix`          | the service: `services.mihomo` + TUN + `metacubexd`           |
| `policy.yaml`          | portable routing policy: ads, CN services, local ranges, tail |
| `generate.nu`          | renders `config.yaml` from `sources.yaml` + `policy.yaml`     |
| `sources.example.yaml` | schema for `sources.yaml`                                     |

Rule order in the output: `private_domains`, your own `rules`, rules imported from sources, then
`policy.yaml`, which closes the list with its `MATCH`.

## Why generate a config at all

A mihomo `proxy-provider` imports proxies only — the `rules` and `proxy-groups` a subscription ships
with are dropped by the core. So the portable part of the policy is written once here, as GEOSITE
categories from meta-rules-dat (`GEOSITE,jd,DIRECT`, `GEOSITE,category-ads-all,REJECT`): a few lines
instead of the thousands a subscription ships.

What a subscription still adds is provider-bound policy — "these domains must use my nodes". If you
want it, `rules_from:` reads a decoded copy of the subscription from `~/.config/mihomo/snapshots/`
and carries its groups, rules and rule-providers over; `file:` does the same for a local Clash YAML.
Skip it for a provider whose policy is just another copy of a public template.

The generator drops malformed rules, a `MATCH` that is not last, and rules pointing at a group it
removed, reporting each instead of writing a config the core rejects.

## Settings worth knowing

- `ipv6: false`: proxy nodes rarely have IPv6 egress, so an AAAA record is a black hole that WeChat,
  JD and Taobao stall on. It also avoids mihomo's IPv6 fake-IP pitfall (`fdfe:dcba:9876::/64`),
  which hangs ssh/git for ~2 minutes.
- `private_domains`: hosts that must never be proxied or fake-IPed; without them `MATCH,PROXY` sends
  them through the tunnel.
- CN consumer services are pinned DIRECT in `policy.yaml` (`GEOSITE,jd`, `GEOSITE,bilibili`,
  `GEOSITE,tencent`). `taobao`, `alipay` and `wechat` are not geosite categories, so those stay
  hand-written. WeChat/QQ images are fetched over bare CDN IPs, hence `multimedia.nt.qq.com.cn` in
  `fake-ip-filter`. If WeChat media still stalls, the fix that worked for the most people in
  clash-verge-rev#1762 is `tun_exclude_process` — on Linux the names are `wechat`, `WeChatAppEx` and
  `qq`; on Windows/macOS `Weixin.exe`, `WeChat`, `WeChatAppEx Helper`. It keeps WeChat off TUN
  entirely and turns `find-process-mode` on by itself. Set `tun_strict_route: false` only if an app
  still misbehaves under TUN.
- `find-process-mode: off` unless a `PROCESS-*` rule or `tun_exclude_process` needs the lookup.
- Rule payloads are bare domains: `DOMAIN-SUFFIX,https://qlogo.cn` is invalid.

## References

- [clash-verge-rev#1762](https://github.com/clash-verge-rev/clash-verge-rev/issues/1762) — WeChat
  media slow or failing under TUN; the thread behind the `fake-ip-filter` and qlogo/qpic choices,
  and the source of the broken `DOMAIN-SUFFIX,https://qlogo.cn` + line-broken `,DIRECT` rule format
  that `generate.nu` sanitizes.
- [community retrospective on WeChat under TUN](https://x.com/realchendahuang/status/2104381806862795161)
  — nodes without IPv6 egress plus AAAA records make a routing black hole; WeChat fetches media over
  bare IPs; JD and Taobao product images break the same way. Why `ipv6: false` and the CN DIRECT
  pins exist.
- [mihomo#3181](https://github.com/MetaCubeX/mihomo/issues/3181) — IPv6 fake-ip
  (`fdfe:dcba:9876::/64`) kills SSH long connections; the reason `ipv6: false` stays on.
- [mihomo wiki](https://wiki.metacubex.one/), especially
  [proxy providers](https://wiki.metacubex.one/config/proxy-providers/) — why the core drops the
  `rules`/`proxy-groups` a subscription ships.
- [meta-rules-dat](https://github.com/MetaCubeX/meta-rules-dat) — the GEOSITE/GEOIP data behind the
  `policy.yaml` categories.
- [metacubexd](https://github.com/MetaCubeX/metacubexd) — the dashboard served at `/ui`.
- [nixpkgs mihomo module](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/networking/mihomo.nix)
  — the service being wrapped: `DynamicUser`, `LoadCredential`, and only `CAP_NET_ADMIN` under
  `tunMode`.
