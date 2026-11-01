# Evaluate with the same pkgs/mkNixPak as the wrappers. Every file under
# ./policy is imported as one app policy suite. Wrapper files are auto-discovered
# from ../nixpaks, so a wrapper and its suite must be added together.
{
  pkgs,
  mkNixPak,
  mylib,
}:
let
  inherit (pkgs) lib;
  ctx = import ./policy-lib.nix { inherit pkgs mkNixPak; };
  suitePaths = mylib.scanPaths ./policy;
  suiteNames = map (path: lib.removeSuffix ".nix" (baseNameOf (toString path))) suitePaths;
  suites = map (path: import path ctx) suitePaths;
  merge =
    acc: suite:
    let
      duplicates = lib.attrNames (lib.intersectAttrs acc suite);
    in
    if duplicates != [ ] then
      throw "duplicate nixpak policy checks: ${lib.concatStringsSep ", " duplicates}"
    else
      acc // suite;
  checks = ctx.globalChecks // lib.foldl' merge { } suites;
  missing = lib.subtractLists suiteNames ctx.appNames;
  orphans = lib.subtractLists ctx.appNames suiteNames;
  failures = builtins.filter (name: !(checks.${name} or false)) (builtins.attrNames checks);
  problems =
    lib.optional (missing != [ ]) "missing policy suites: ${lib.concatStringsSep ", " missing}"
    ++ lib.optional (orphans != [ ]) "orphan policy suites: ${lib.concatStringsSep ", " orphans}"
    ++ lib.optional (failures != [ ]) "failed checks:\n - ${lib.concatStringsSep "\n - " failures}";
in
if problems == [ ] then
  true
else
  throw "nixpak policy check failed:\n${lib.concatStringsSep "\n" problems}"
