# Mihomo

Native mihomo core + metacubexd dashboard, replacing the Clash Verge GUI. Enable per host with
`modules.networking.mihomo.enable = true` (`ai`, `shoukei`).

## Usage

```sh
cp sources.example.yaml ~/.config/mihomo/sources.yaml && chmod 600 ~/.config/mihomo/sources.yaml
$EDITOR ~/.config/mihomo/sources.yaml           # fill in: secret, private_domains, providers
just mihomo-gen                                 # -> ~/.config/mihomo/config.yaml, mode 0600
sudo systemctl restart mihomo.service           # dashboard: http://127.0.0.1:9090/ui
```

`~/.config/mihomo` holds only `sources.yaml` and the generated `config.yaml` (plus geodata and the
cache); the generator, `policy.yaml` and `gateway-config.nu` are run from here and never copied
over. `just mihomo-gen` renders the config and validates it with the core the service runs.

`sources.yaml` holds everything private (subscription URLs, secret, private domains) and stays out
of the repo and the Nix store; the module loads `config.yaml` via `LoadCredential`. Generate the
config before enabling the module, or the service will not start.

## Files

| File                   | Role                                                          |
| ---------------------- | ------------------------------------------------------------- |
| `default.nix`          | the service: `services.mihomo` + TUN + `metacubexd`           |
| `policy.yaml`          | portable routing policy: ads, CN services, local ranges, tail |
| `generate.nu`          | renders `config.yaml` from `sources.yaml` + `policy.yaml`     |
| `gateway-config.nu`    | the same output plus the gateway deltas                       |
| `sources.example.yaml` | schema for `sources.yaml`                                     |

Rule order: `private_domains`, your `rules`, imported rules, then `policy.yaml`, ending in `MATCH`.

The gateway (`suzi`, not a host in this flake) runs the same config with a fixed set of deltas --
`gateway-config.nu` renders it, `--redact` for a shareable template. Its output carries the
subscriptions, so never commit it; the secret is filled in on the box, not here.

## Why generate

`proxy-provider` imports proxies only — a subscription's rules and groups are dropped by the core.
The portable policy is therefore written once in `policy.yaml` as GEOSITE categories. Provider-bound
policy is opt-in: `rules_from:` (a decoded snapshot) or `file:` carry groups, rules and
rule-providers over. The generator drops and reports malformed rules, misplaced `MATCH` and orphaned
targets instead of writing a config the core rejects.

## Gotchas

- `ipv6`, `dns.ipv6`, `fake-ip-range6`: the fake v6 pool is a lookup key, so the family the client
  picks never picks the egress family -- a fake-IPv6 client dials an IPv4 proxy target, and CN
  services answer identically over `-6` and `-4`. What does break is a fake v6 pool on a line whose
  IPv6 is dead: apps that resolve for themselves (WeChat) dial a real AAAA, stall, and do not fall
  back. mihomo has no IPv6 reachability probe (mihomo#2233), so the config has to match the line.
  SSH over a fake AAAA is the local exception: it connects, authenticates, then never closes --
  WA-028's IPv4 pin covers it.
- `private_domains`: each entry becomes a DIRECT rule + a `fake-ip-filter` entry.
- WeChat resolves for itself, but its queries still cross the TUN, so `dns-hijack: any:53` catches
  them and the fake-ip table hands the name back to the rules: `mmbiz.qpic.cn` measured DIRECT.
  `multimedia.nt.qq.com.cn` stays in `fake-ip-filter` for the same reason. The exclude-process fix
  that won clash-verge-rev#1762 is not available here: `hardening/bwraps/wechat.nix` sets
  `unsharePid = true` and the sandbox reports uid 0, so no process name resolves.
- `find-process-mode: off` unless `PROCESS-*` rules or `tun_exclude_process` need it.
- `tun_exclude_address`: a destination that can never be a proxy target should not pay a fake-ip
  round trip -- RFC1918, RFC 6598's `100.64.0.0/10` (where Tailscale addresses come from),
  link-local, multicast, reserved and documentation prefixes, the cluster ULA `fd05:5::/64` and
  Tailscale's `fd7a:115c:a1e0::/48`. Never exclude a range that holds a fake-ip pool: that is
  `198.18.0.0/16` and `fdfe:dcba:9876::/64`, which is why the list spells the two ULAs out instead
  of taking `fc00::/7`; `tun_exclude_address: []` puts everything back in TUN.
- Steam's download caches follow the public IP Steam sees on the login (CM) connection, so a proxied
  Steam downloads from Tokyo/Singapore/HK/Los Angeles. `policy.yaml` pins the CM hosts,
  `steamcontent.com` and `IP-ASN,32590` DIRECT and keeps `steamcommunity.com` on the proxy -- Steam
  dials cached CM addresses without a lookup, so that rule is not decoration. Not `GEOSITE,steam`:
  that category includes the community. Sources and how to verify: "Steam download region" below.
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

## Steam download region

Steam hands the client a content-server list keyed by a `cell_id`, and the cell follows the public
IP Steam sees on the login (CM) connection. A proxied login means a foreign cell, which means
foreign download caches. Nothing in the Steam client overrides that. What the Steam rules in
`policy.yaml` rest on, and how far to trust each source:

| Source                                                                                                                                                    | Establishes                                                                                                                                                  | Trust                                                                                                                 |
| --------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------- |
| [Valve's content-server directory API](https://api.steampowered.com/IContentServerDirectoryService/GetServersForSteamPipe/v1/?cell_id=0&max_servers=2000) | the list is keyed by `cell_id`; `cell_id=0` means "use geolocation". Ask for any cell with `?cell_id=<n>&max_servers=2000`                                   | Valve, live, authoritative                                                                                            |
| `~/.local/share/Steam/logs/content_log.txt`                                                                                                               | what this host actually got: 2024 (CellID 201) came from mainland CDN partners, 2025-2026 (CellID 171/177) from the `tyo3`/`sgp1`/`hkg1`/`lax1` Valve caches | your own client, the strongest evidence here                                                                          |
| [羽翼城 / Dogfight360](https://www.dogfight360.com/blog/knowledge-base/fix_steamdl_region/)                                                               | the trick itself: pin `*.cm.steampowered.com`, `*.steamserver.net` and Valve's ranges direct; 2022 article, still maintained (2026-05)                       | the origin every other recipe copies; single-operator, but the mechanism checks out against the API and the local log |
| [femoon](https://femoon.top/blog/steam-slow-download-clash-split-routing), [teapotium](https://teapotium.com/2024/12/let-steam-downloads-bypass-proxy/)   | the same rules for Clash/mihomo, and the CM-IP-cached-without-DNS detail                                                                                     | derivative reports; their prefix lists are stale, which is why the config matches on the ASN                          |
| [RIPE stat: AS32590 announced prefixes](https://stat.ripe.net/data/announced-prefixes/data.json?resource=AS32590)                                         | which ranges Valve actually owns today                                                                                                                       | registry data; cross-checks what the ASN match covers                                                                 |
| [meta-rules-dat](https://github.com/MetaCubeX/meta-rules-dat)                                                                                             | geosite category names: `steam` and `category-games` exist, `category-games@cn` (in several guides) does not                                                 | upstream data, checked against `GeoSite.dat` (2026-10)                                                                |

Two things that look like levers and are not: the Download Region dropdown -- since 2024-10-04 it
[selects no CDN at all](https://tpill90.github.io/steam-lancache-prefill/en/steam-docs/CDN-Regions/)
-- and `CellIDServerOverride` in `config.vdf`, pinned to 35 (Singapore) on this host while the log
shows downloads arriving from Tokyo. The IP Steam sees is the only lever.

Check the result with `steam://open/console` then `user_info` (`IPCountry` must read `CN`), and by
listing the cache groups the client was actually served:

```sh
grep -oE 'cache[0-9]+-[a-z]{3}[0-9]+' ~/.local/share/Steam/logs/content_log.txt |
  sed -E 's/^cache[0-9]+-//' | sort -u
```

## References

- [clash-verge-rev#1762](https://github.com/clash-verge-rev/clash-verge-rev/issues/1762) — WeChat
  media under TUN: fake-ip-filter, qlogo/qpic, the exclude-process fix. Its closing comment is the
  one that matters: a fake v6 pool works on a line with working IPv6 and hangs on a line without.
- [mihomo#2233](https://github.com/MetaCubeX/mihomo/issues/2233) — open: the core has no IPv6
  reachability probe, so `ipv6` cannot stay on for a line that lost IPv6.
- [WeChat-under-TUN retrospective](https://x.com/realchendahuang/status/2104381806862795161) — five
  community fixes; "turn IPv6 off" only ever worked where the line's IPv6 was already broken.
- [mihomo wiki](https://wiki.metacubex.one/),
  [proxy providers](https://wiki.metacubex.one/config/proxy-providers/) — why subscription rules are
  dropped.
- [meta-rules-dat](https://github.com/MetaCubeX/meta-rules-dat) — the GEOSITE/GEOIP data.
- [metacubexd](https://github.com/MetaCubeX/metacubexd) — the dashboard.
- [nixpkgs mihomo module](https://github.com/NixOS/nixpkgs/blob/nixos-unstable/nixos/modules/services/networking/mihomo.nix)
  — `DynamicUser`, `LoadCredential`, only `CAP_NET_ADMIN` under `tunMode`.
