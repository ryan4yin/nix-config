#!/usr/bin/env nu
# Generate ~/.config/mihomo/config.yaml from ~/.config/mihomo/sources.yaml:
#
#   nu generate.nu [-s sources.yaml] [-o config.yaml]
#
# sources.yaml is the only file you edit. It holds secrets, so keep it mode 0600
# and never commit it. README.md explains why the config is generated and what
# the keys mean; sources.example.yaml is the schema.
# ---------------------------------------------------------------------------

const HEALTH_URL = "https://www.gstatic.com/generate_204"

# The portable tail -- dns fake-ip-filter entries, optional rule-providers and
# the rules that close every config -- lives in policy.yaml next to this script.

# ---------------------------------------------------------------------------
# small helpers
# ---------------------------------------------------------------------------

def fail [msg: string] {
  error make { msg: $msg }
}

# drop keys whose value is null or an empty list, to keep the output readable
def clean [rec: record] {
  let drop = (
    $rec
    | columns
    | where { |c|
      let v = ($rec | get $c)
      if ($v == null) {
        true
      } else if (($v | describe) | str starts-with "list") {
        ($v | length) == 0
      } else {
        false
      }
    }
  )
  if ($drop | is-empty) {
    $rec
  } else {
    $rec | reject ...$drop
  }
}

def dupes [names: list<string>] {
  $names
  | group-by
  | items { |k, v| if (($v | length) > 1) { $k } else { null } }
  | where { |x| $x != null }
}

def node-names [doc: record] {
  $doc
  | get -o proxies
  | default []
  | each { |p| ($p | get -o name) }
  | where { |n| $n != null }
}

# mihomo has no wildcard rule type, so a private_domains entry is normalized to
# a bare domain: `DOMAIN-SUFFIX` already matches the apex and every label below
# it, which is what `*.lab.example.com` means anyway.
def private_bare [d: string] {
  let bare = (($d | str trim) | str replace --all --regex '^\*\.' "")
  if ($bare | str contains "*") {
    fail $"private_domains entry '($d)': mihomo has no wildcard rules, use a plain domain or a leading '*.'"
  }
  $bare
}

def private-rule [d: string] {
  let bare = (private_bare $d)
  if ($bare | is-empty) {
    return null
  }
  $"DOMAIN-SUFFIX,($bare),DIRECT"
}

# fake-ip-filter entry: `+.d` matches the apex and all labels
def private-filter [d: string] {
  let bare = (private_bare $d)
  if ($bare | is-empty) {
    return null
  }
  $"+.($bare)"
}

# rewrite whole comma-separated fields, so both `...,<group>` and composite
# rules such as `AND,(...),<group>` get remapped
def rewrite-rule [rule: string, map: record] {
  $rule
  | split row ","
  | each { |part|
    let t = ($part | str trim)
    if ($t in $map) { $map | get $t } else { $part }
  }
  | str join ","
}

# Rules copied out of a browser or a chat log often carry a scheme, e.g.
# `DOMAIN-SUFFIX,https://qlogo.cn,DIRECT`; mihomo rejects that. A rule split
# across two lines (`DOMAIN-SUFFIX,https://qlogo.cn` then `,DIRECT`) becomes two
# invalid entries. Fix the scheme, drop what is still broken, and say so.
#
# A `MATCH` rule from a source or from `sources.yaml` is dropped: it is a
# catch-all, so keeping one there would shadow every policy rule after it.
# policy.yaml may keep one, but only as its last rule, which is where the
# catch-all belongs.
def sanitize-rules [rules: list<any>, who: string, keep_match: bool = false] {
  mut ok = []
  mut bad = []
  let last = (($rules | length) - 1)
  for e in ($rules | enumerate) {
    let i = $e.index
    let raw = ($e.item | into string | str trim)
    if ($raw | is-empty) {
      continue
    }
    let fixed = ($raw | str replace --all --regex '(?i)\bhttps?://' "")
    let parts = ($fixed | split row ",")
    let head = ($parts | first | default "" | str trim | str uppercase)
    let tail = ($parts | last | default "" | str trim)
    if ($head == "MATCH") and ($keep_match and ($i == $last)) {
      $ok = ($ok ++ [$fixed])
    } else if ($head == "MATCH") {
      $bad = ($bad ++ [$"($who): catch-all dropped, it belongs last: ($raw)"])
    } else if (($parts | length) < 3) or ($head | is-empty) or ($tail | is-empty) {
      $bad = ($bad ++ [$"($who): malformed rule dropped: ($raw)"])
    } else {
      $ok = ($ok ++ [$fixed])
    }
  }
  { ok: $ok, bad: $bad }
}

# PROCESS-* rules and tun.exclude-process both need the core to look up the
# owning process, which `find-process-mode: off` disables.
def process_mode [rules: list<string>, excluded: list<string>] {
  let needs = (
    ($rules | any { |r| ($r | str uppercase | str contains "PROCESS-") })
    or (($excluded | length) > 0)
  )
  if $needs {
    "always"
  } else {
    "off"
  }
}

# ---------------------------------------------------------------------------
# importing groups / rules / rule-providers from a local YAML copy
# ---------------------------------------------------------------------------

# Node names are replaced by a provider reference so that a subscription
# refresh (nodes come and go) cannot break the imported groups. A group named
# exactly like its provider is dropped and remapped onto the "<name> 节点"
# group this generator already builds, because a proxy-provider and a
# proxy-group cannot share a name.
def import-doc [doc: record, provider: string] {
  let names = (node-names $doc)
  let own_group = $"($provider) 节点"
  let map = ({ ($provider): $own_group })

  let groups = (
    $doc
    | get -o proxy-groups
    | default []
    | where { |g| (($g | get -o name | default "") | str trim) != $provider }
    | each { |g|
      let declared = ($g | get -o proxies | default [])
      let kept = (
        $declared
        | each { |x|
          let t = ($x | into string | str trim)
          if ($t in $map) { $map | get $t } else { $x }
        }
        | where { |x| not (($x | into string) in $names) }
      )
      let refs = ($declared | where { |x| ($x | into string) in $names })
      let use_list = (($g | get -o use | default []) ++ (if ($refs | is-empty) { [] } else { [$provider] }))
      clean ($g | upsert 'proxies' $kept | upsert 'use' $use_list)
    }
    | where { |g|
      let np = (($g | get -o proxies | default []) | length)
      let n_use = (($g | get -o use | default []) | length)
      ($np > 0) or ($n_use > 0) or (($g | get -o include-all | default false) == true)
    }
  )

  let rules = (sanitize-rules ($doc | get -o rules | default []) $"($provider) snapshot")
  # a rule pointing at a group this generator dropped would make the core refuse
  # the whole config, so drop the rule and report it instead
  let kept = ($groups | each { |g| $g.name })
  let dropped = (
    $doc
    | get -o proxy-groups
    | default []
    | each { |g| ($g | get -o name | default "") | str trim }
    | where { |n| (not ($n in $kept)) and ($n != $provider) }
  )
  mut final_rules = []
  mut orphans = []
  for r in ($rules.ok | each { |x| rewrite-rule $x $map }) {
    let target = ($r | split row "," | last | default "" | str trim)
    if ($target in $dropped) {
      $orphans = ($orphans ++ [$"($provider) snapshot: rule target has no group, dropped: ($r)"])
    } else {
      $final_rules = ($final_rules ++ [$r])
    }
  }
  {
    groups: $groups
    rules: $final_rules
    bad_rules: ($rules.bad ++ $orphans)
    "rule-providers": ($doc | get -o rule-providers | default {})
  }
}

def open-doc [path: string, who: string] {
  let f = ($path | path expand)
  if not ($f | path exists) {
    fail $"($who): file not found: ($f)"
  }
  let doc = (
    try {
      open $f
    } catch {
      fail $"($who): ($f) is not readable as YAML/JSON. Save the decoded subscription, the provider's Clash YAML, not a base64 payload."
    }
  )
  if (($doc | describe) | str starts-with "record") {
    $doc
  } else {
    fail $"($who): ($f) has no top-level mapping"
  }
}

# ---------------------------------------------------------------------------
# providers
# ---------------------------------------------------------------------------

def health-check [] {
  { enable: true, url: $HEALTH_URL, interval: 300 }
}

# -> { name, provider, groups, rules, bad_rules, rule-providers }
def build-entry [p: record] {
  let name = ($p | get -o name | default "" | str trim)
  if ($name | is-empty) {
    fail "every provider needs a `name`"
  }
  let url = ($p | get -o url)
  let file = ($p | get -o file)
  let rules_from = ($p | get -o rules_from)

  if ($url != null) {
    let provider = {
      type: "http"
      url: $url
      interval: ($p | get -o interval | default 86400)
      path: $"./providers/($name).yaml"
      "health-check": (health-check)
    }
    let imported = (
      if ($rules_from != null) {
        import-doc (open-doc $rules_from $"provider ($name)") $name
      } else {
        { groups: [], rules: [], bad_rules: [], "rule-providers": {} }
      }
    )
    {
      name: $name
      provider: $provider
      groups: $imported.groups
      rules: $imported.rules
      bad_rules: $imported.bad_rules
      "rule-providers": $imported."rule-providers"
    }
  } else if ($file != null) {
    # a local YAML file: inline its proxies (the service user cannot read files
    # under /home), and carry over its groups, rules and rule-providers too
    let doc = (open-doc $file $"provider ($name)")
    let payload = ($doc | get -o proxies)
    if (($payload == null) or (($payload | describe) | str starts-with "list") and (($payload | length) == 0)) {
      fail $"provider ($name): ($file) has no top-level `proxies:` list"
    }
    let provider = {
      type: "inline"
      "health-check": (health-check)
      payload: $payload
    }
    let imported = (import-doc $doc $name)
    {
      name: $name
      provider: $provider
      groups: $imported.groups
      rules: $imported.rules
      bad_rules: $imported.bad_rules
      "rule-providers": $imported."rule-providers"
    }
  } else {
    fail $"provider ($name): set either `url` or `file`"
  }
}

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

def main [
  --sources (-s): path = "~/.config/mihomo/sources.yaml"
  --out (-o): path = "~/.config/mihomo/config.yaml"
  --policy (-p): path
] {
  let src = ($sources | path expand)
  let out = ($out | path expand)
  let pol = (
    if $policy == null {
      ($env.FILE_PWD | path join "policy.yaml")
    } else {
      $policy | path expand
    }
  )
  if not ($src | path exists) {
    fail $"sources file not found: ($src) -- copy sources.example.yaml to sources.yaml first"
  }
  if not ($pol | path exists) {
    fail $"policy file not found: ($pol)"
  }

  # the portable tail: fake-ip-filter entries, optional rule-providers, rules
  let policy_doc = (open $pol)
  let policy_filters = ($policy_doc | get -o dns_filters | default [])
  let policy_rules = (sanitize-rules ($policy_doc | get -o rules | default []) "policy.yaml" true)
  let policy_rp = ($policy_doc | get -o rule_providers | default {})

  let spec = (open $src)
  let declared = ($spec | get -o providers | default [])
  if ($declared | is-empty) {
    print --stderr "warning: no providers defined; everything will go DIRECT"
  }

  let names = ($declared | each { |p| ($p | get -o name | default "") })
  let name_dups = (dupes $names)
  if ($name_dups | is-not-empty) {
    fail $"duplicate provider names: ($name_dups | str join ', ')"
  }

  let entries = ($declared | each { |p| build-entry $p })

  let providers_map = (
    $entries
    | reduce --fold {} { |it, acc| $acc | insert $it.name ($it.provider) }
  )

  # groups: entry point + one select per provider + everything the sources declare
  let per_provider = ($names | each { |n| { name: $"($n) 节点", type: "select", use: [$n] } })
  let imported_groups = ($entries | each { |e| $e.groups } | flatten)
  let groups = (
    [
      { name: "PROXY", type: "select", proxies: (["AUTO"] ++ ($per_provider | get name) ++ ["DIRECT"]) }
      { name: "AUTO", type: "url-test", use: $names, url: $HEALTH_URL, interval: 300 }
    ]
    ++ $per_provider
    ++ $imported_groups
  )
  let group_dups = (dupes ($groups | each { |g| $g.name }))
  if ($group_dups | is-not-empty) {
    fail $"duplicate proxy-group names: ($group_dups | str join ', ')"
  }

  # rule-providers: the policy file first, then every source document
  let rule_providers = (
    ([$policy_rp] ++ ($entries | each { |e| $e."rule-providers" }))
    | reduce --fold {} { |it, acc|
      $it | columns | reduce --fold $acc { |k, a| $a | insert $k ($it | get $k) }
    }
  )
  let rp_dups = (dupes ($rule_providers | columns))
  if ($rp_dups | is-not-empty) {
    fail $"duplicate rule-provider names: ($rp_dups | str join ', ')"
  }

  let priv = ($spec | get -o private_domains | default [])
  let priv_rules = ($priv | each { |d| private-rule $d } | where { |x| $x != null })
  let priv_filters = ($priv | each { |d| private-filter $d } | where { |x| $x != null })
  let user_rules = (sanitize-rules ($spec | get -o rules | default []) "sources.rules")
  let imported_rules = ($entries | each { |e| $e.rules } | flatten)
  let bad_rules = (($entries | each { |e| $e.bad_rules } | flatten) ++ $user_rules.bad ++ $policy_rules.bad)

  let excluded = ($spec | get -o tun_exclude_process | default [])
  # evaluation order: private hosts, hand-written rules, provider rules, policy tail
  let body_rules = ($priv_rules ++ $user_rules.ok ++ $imported_rules ++ $policy_rules.ok)
  # the core needs a catch-all; policy.yaml normally supplies it as its last rule
  let has_catch_all = ($body_rules | last | default "" | str uppercase | str starts-with "MATCH")
  let all_rules = ($body_rules ++ (if $has_catch_all { [] } else { ["MATCH,PROXY"] }))
  let fpm = (process_mode $all_rules $excluded)

  let config = {
    # IPv6 stays off on purpose: most proxy nodes have no IPv6 egress, so an
    # AAAA record becomes a routing black hole that apps such as WeChat, JD,
    # Taobao and Feishu sit on until they fall back to IPv4.
    ipv6: false
    mode: "rule"
    "mixed-port": 7897
    "allow-lan": false
    "log-level": "warning"
    "unified-delay": true
    tcp-concurrent: true
    "find-process-mode": $fpm
    "external-controller": "127.0.0.1:9090"
    secret: ($spec | get -o secret | default "CHANGE_ME")
    "external-controller-cors": {
      "allow-private-network": true
      "allow-origins": ["http://127.0.0.1:9090", "http://localhost:9090"]
    }
    profile: { "store-selected": true, "store-fake-ip": true }
    tun: (
      clean ({
        enable: true
        stack: "gvisor"
        "auto-route": true
        "strict-route": ($spec | get -o tun_strict_route | default true)
        "auto-detect-interface": true
        "dns-hijack": ["any:53"]
      } | upsert 'exclude-process' $excluded)
    )
    dns: {
      enable: true
      listen: ":53"
      ipv6: false
      "enhanced-mode": "fake-ip"
      "fake-ip-range": "198.18.0.1/16"
      "fake-ip-filter-mode": "blacklist"
      "prefer-h3": false
      "respect-rules": false
      "use-hosts": false
      "use-system-hosts": false
      "default-nameserver": ["223.5.5.5" "119.29.29.29" "223.6.6.6"]
      nameserver: ["223.5.5.5" "119.29.29.29" "https://dns.alidns.com/dns-query"]
      "proxy-server-nameserver": ["223.5.5.5" "https://dns.alidns.com/dns-query" "tls://223.5.5.5"]
      "fake-ip-filter": (($priv_filters | append $policy_filters) | uniq)
    }
    "geodata-mode": false
    "geo-auto-update": true
    "geo-update-interval": 24
    "geox-url": {
      geoip: "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geoip.dat"
      geosite: "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/geosite.dat"
      mmdb: "https://testingcf.jsdelivr.net/gh/MetaCubeX/meta-rules-dat@release/country.mmdb"
    }
    "proxy-providers": $providers_map
    "proxy-groups": $groups
    "rule-providers": $rule_providers
    rules: ($all_rules | uniq)
  }

  $config | to yaml | save --force $out
  ^chmod 600 $out

  let breakdown = $"private ($priv_rules | length), user ($user_rules.ok | length), imported ($imported_rules | length), policy ($policy_rules.ok | length)"
  print $"wrote ($out)"
  print $"  providers:         ($names | str join ', ')"
  print $"  proxy-groups:      ($groups | length)"
  print $"  rule-providers:    ($rule_providers | columns | length)"
  print $"  rules:             (($config | get rules) | length)  -- ($breakdown)"
  print $"  find-process-mode: ($fpm)"
  if ($bad_rules | is-not-empty) {
    print --stderr $"warning: dropped ($bad_rules | length) rules:"
    for b in $bad_rules {
      print --stderr $"  ($b)"
    }
  }
}
