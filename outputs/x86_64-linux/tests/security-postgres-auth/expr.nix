{
  lib,
  outputs,
}:
let
  cfg = outputs.nixosConfigurations.youko.config;
  auth = cfg.services.postgresql.authentication;
  lines = lib.splitString "\n" auth;
  fields = line: builtins.filter (s: s != "") (lib.splitString " " line);
  hasLine = want: builtins.any (line: fields line == want) lines;
  indexOf =
    want:
    let
      go =
        i: xs:
        if xs == [ ] then
          null
        else if fields (builtins.head xs) == want then
          i
        else
          go (i + 1) (builtins.tail xs);
    in
    go 0 lines;
in
lib.genAttrs (builtins.attrNames outputs.nixosConfigurations) (
  name:
  if name != "youko" then
    true
  else
    # The superuser and replication rows must require a password, and the
    # postgres row must precede the generic loopback trust row (first match wins).
    hasLine [
      "host"
      "all"
      "postgres"
      "127.0.0.1/32"
      "scram-sha-256"
    ]
    && hasLine [
      "host"
      "replication"
      "all"
      "127.0.0.1/32"
      "scram-sha-256"
    ]
    && hasLine [
      "host"
      "all"
      "all"
      "127.0.0.1/32"
      "trust"
    ]
    &&
      indexOf [
        "host"
        "all"
        "postgres"
        "127.0.0.1/32"
        "scram-sha-256"
      ] < indexOf [
        "host"
        "all"
        "all"
        "127.0.0.1/32"
        "trust"
      ]
)
