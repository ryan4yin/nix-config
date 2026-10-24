{
  lib,
  myvars,
  outputs,
}:
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (
  name:
  let
    config = outputs.nixosConfigurations.${name}.config;
    rules = config.networking.firewall.extraInputRules;
    # Evaluate the actual merged rule ordering, including k3s pod-network rules.
    beforeTrust = builtins.head (lib.splitString "iifname \"podman0\" accept" rules);
    ipv6Guard = "meta nfproto ipv6 tcp dport { 9100, 9835, 9633 } drop";
    monitoringHost = myvars.networking.hostsAddr.youko.ipv4;
    generated = config.networking.nftables.tables.nixos-fw.content;
    # rpfilter accepts valid source routes before input filtering; that is not
    # service access. Compare trust/denial ordering within input-allow only.
    inputAllow = builtins.head (
      lib.splitString "\n}" (lib.last (lib.splitString "chain input-allow {" generated))
    );
    broadTrustRules = lib.filter (
      line:
      lib.hasSuffix " accept" line
      && (
        lib.hasInfix "saddr" line || lib.hasInfix "\"podman0\"" line || lib.hasInfix "\"tailscale0\"" line
      )
    ) (map lib.strings.trim (lib.splitString "\n" inputAllow));
    exporterGuards = [
      ipv6Guard
    ]
    ++ map (port: "ip saddr != ${monitoringHost} tcp dport ${toString port} drop") [
      9100
      9835
      9633
    ];
  in
  {
    ipv4Restricted =
      lib.all
        (port: lib.hasInfix "ip saddr != ${monitoringHost} tcp dport ${toString port} drop" beforeTrust)
        [
          9100
          9835
          9633
        ];
    # Every enabled exporter must bind this host's static LAN IPv4, not the
    # nixpkgs default 0.0.0.0 (audit 2026-10-22 found the nvidia exporter wild).
    exportersBoundToLan =
      let
        lanAddr = myvars.networking.hostsAddr.${config.networking.hostName}.ipv4 or null;
        exporters = [
          config.services.prometheus.exporters.node
          config.services.prometheus.exporters.smartctl
          config.services.prometheus.exporters.nvidia-gpu
        ];
      in
      lib.all (e: !e.enable || e.listenAddress == lanAddr) exporters;
    ipv6RestrictedBeforeTrust = lib.hasInfix ipv6Guard beforeTrust;
    generatedRestrictionsBeforeTrust =
      broadTrustRules != [ ]
      && lib.all (
        trust:
        lib.all (
          guard: lib.hasInfix guard (builtins.head (lib.splitString trust inputAllow))
        ) exporterGuards
      ) broadTrustRules;
    lanRetained = lib.hasInfix "ip  saddr ${myvars.networking.lanCidr} accept" rules;
    tailnetRetained = lib.hasInfix "iifname \"tailscale0\" accept" rules;
  }
)
