# Mihomo

Native mihomo core + metacubexd dashboard, replacing the Clash Verge GUI. Enable per host with
`modules.networking.mihomo.enable = true` (`ai`, `shoukei`).

## Usage

```sh
cp sources.example.yaml ~/.config/mihomo/sources.yaml && chmod 600 ~/.config/mihomo/sources.yaml
$EDITOR ~/.config/mihomo/sources.yaml           # fill in: secret, private_domains, providers
nu generate.nu                                  # -> ~/.config/mihomo/config.yaml, mode 0600
mihomo -t -f ~/.config/mihomo/config.yaml       # validate before restarting
sudo systemctl restart mihomo.service           # dashboard: http://127.0.0.1:9090/ui
```

`sources.yaml` holds everything private (subscription URLs, secret, private domains) and stays out
of the repo and the Nix store; the module loads `config.yaml` via `LoadCredential`. Generate the
config before enabling the module, or the service will not start.

## Files

| File                   | Role                                                          |
| ---------------------- | ------------------------------------------------------------- |
| `default.nix`          | the service: `services.mihomo` + TUN + `metacubexd`           |
| `policy.yaml`          | portable routing policy: ads, CN services, local ranges, tail |
| `generate.nu`          | renders `config.yaml` from `sources.yaml` + `policy.yaml`     |
| `sources.example.yaml` | schema for `sources.yaml`                                     |

Rule order: `private_domains`, your `rules`, imported rules, then `policy.yaml`, ending in `MATCH`.

## Why generate

`proxy-provider` imports proxies only — a subscription's rules and groups are dropped by the core.
The portable policy is therefore written once in `policy.yaml` as GEOSITE categories. Provider-bound
policy is opt-in: `rules_from:` (a decoded snapshot) or `file:` carry groups, rules and
rule-providers over. The generator drops and reports malformed rules, misplaced `MATCH` and orphaned
targets instead of writing a config the core rejects.

## Gotchas

- `ipv6: false`: nodes without IPv6 egress + AAAA = routing black hole (WeChat/JD/Taobao images);
  mihomo's IPv6 fake-ip also hung ssh/git locally for ~2 minutes, so it stays off.
- `private_domains`: each entry becomes a DIRECT rule + a `fake-ip-filter` entry.
- WeChat/QQ media go over bare CDN IPs, hence `multimedia.nt.qq.com.cn` in `fake-ip-filter`. If
  media still stalls: `tun_exclude_process: [wechat, WeChatAppEx, qq]` (Linux names; the fix that
  won clash-verge-rev#1762).
- `find-process-mode: off` unless `PROCESS-*` rules or `tun_exclude_process` need it.
- CDN selection depends on launcher probes, not the patch download route. On this host,
  `launcher-webstatic.hoyoverse.com` went through a US proxy node while `autopatchcn.bhsr.com` was
  DIRECT; the download rose from ~0.5 to 102 MB/s after the proxy group was switched to DIRECT.
  `policy.yaml` bypasses proxy only for that observed probe, not game CDNs or broad vendor domains.
  Verify future probes in `/connections` and add only confirmed hosts. Reference:
  [HoyoPlay API endpoints](https://gist.github.com/DynamiByte/0ad250bbe1930e2736a6d4e6e842bcb2).
- Rule payloads are bare domains: `DOMAIN-SUFFIX,https://qlogo.cn` is invalid.
- On a systemd-resolved host, sing-tun normally points resolved at the TUN DNS with `resolvectl`.
  The nixpkgs `DynamicUser` sandbox cannot make those privileged D-Bus changes, so resolved's own
  upstream queries bypass `dns-hijack any:53` and leave via the NIC. Tie a resolver takeover to the
  service lifetime (`resolvectl dns`/`revert` in `ExecStartPost`/`ExecStopPost`, see
  `hosts/idols-ai/default.nix`), prefixed with `+` to run outside the unit sandbox. Never set link
  DNS statically to mihomo: a dead mihomo would take DNS down with it, and resolved does not fall
  back.

## References

- [clash-verge-rev#1762](https://github.com/clash-verge-rev/clash-verge-rev/issues/1762) — WeChat
  media under TUN: fake-ip-filter, qlogo/qpic, the exclude-process fix.
- [WeChat-under-TUN retrospective](https://x.com/realchendahuang/status/2104381806862795161) — the
  IPv6 black hole logic; JD and Taobao break the same way.
- [mihomo wiki](https://wiki.metacubex.one/),
  [proxy providers](https://wiki.metacubex.one/config/proxy-providers/) — why subscription rules are
  dropped.
- [meta-rules-dat](https://github.com/MetaCubeX/meta-rules-dat) — the GEOSITE/GEOIP data.
- [metacubexd](https://github.com/MetaCubeX/metacubexd) — the dashboard.
- [nixpkgs mihomo module](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/networking/mihomo.nix)
  — `DynamicUser`, `LoadCredential`, only `CAP_NET_ADMIN` under `tunMode`.
