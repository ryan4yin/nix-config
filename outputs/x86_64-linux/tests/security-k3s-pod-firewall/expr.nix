{
  lib,
  outputs,
}:
let
  # Index of the first occurrence of `needle` in `haystack`, or null.
  firstIndex =
    needle: haystack:
    let
      parts = lib.splitString needle haystack;
    in
    if builtins.length parts < 2 then null else builtins.stringLength (builtins.head parts);
in
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (
  name:
  let
    cfg = outputs.nixosConfigurations.${name}.config;
    rules = cfg.networking.firewall.extraInputRules;
    dropAt = firstIndex "saddr 10.0.0.0/8 tcp dport" rules;
    acceptAt = firstIndex "saddr 10.0.0.0/8 accept" rules;
  in
  if !(cfg.services.k3s.enable or false) then
    true
  else
    # The port deny must exist and must precede the broad pod accept, because
    # nftables takes the first matching rule.
    dropAt != null
    && acceptAt != null
    && dropAt < acceptAt
    && lib.hasInfix "2049" rules
    && lib.hasInfix "5432" rules
    && lib.hasInfix "5902" rules
)
