{
  lib,
  load,
  mkAppPolicy,
  gamingChecks,
  ...
}:
let
  app = load "umu";
in
mkAppPolicy "umu" {
  network = "pasta";
  media = false;
  pulse = true;
  x11 = true;
  notifications = false;
  extraChecks = gamingChecks "umu" // {
    # DW-Proton comes from the store, which a game can read but not modify.
    protonPath = lib.hasPrefix builtins.storeDir app.bubblewrap.env.UMU_PROTONPATH;
  };
}
