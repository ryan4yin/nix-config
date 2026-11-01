{
  lib,
  ...
}:
let
  yes = lib.genAttrs [
    "ai-niri"
    "shoryu"
    "shushou"
    "youko"
  ] (_: true);
in
{
  distributedBuilds = yes;
  aquamarineConfigured = yes;
}
