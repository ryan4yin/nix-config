# Shared systemd sandboxing preset, adapted from xddxdd's serviceHardenArgs
# (github.com/xddxdd/nixos-config, nixos/minimal-modules/harden.nix).
{ lib }:
rec {
  # For a network daemon that runs as an unprivileged user and only needs its
  # own state; override keys where a service needs more.
  service = {
    AmbientCapabilities = "";
    CapabilityBoundingSet = "";
    LockPersonality = true;
    MemoryDenyWriteExecute = true;
    NoNewPrivileges = true;
    PrivateDevices = true;
    PrivateMounts = true;
    PrivateTmp = true;
    ProcSubset = "pid";
    ProtectClock = true;
    ProtectControlGroups = true;
    ProtectHome = true;
    ProtectHostname = true;
    ProtectKernelLogs = true;
    ProtectKernelModules = true;
    ProtectKernelTunables = true;
    ProtectProc = "invisible";
    ProtectSystem = "strict";
    RemoveIPC = true;
    RestrictAddressFamilies = [
      "AF_UNIX"
      "AF_INET"
      "AF_INET6"
    ];
    RestrictNamespaces = true;
    RestrictRealtime = true;
    RestrictSUIDSGID = true;
    SystemCallArchitectures = "native";
    # Fail a denied syscall rather than kill the service while it is new to
    # the preset; switch to "kill" once it has run stably.
    SystemCallErrorNumber = "EPERM";
    SystemCallFilter = [
      "@system-service"
      "~@clock @cpu-emulation @debug @module @mount @obsolete @privileged @raw-io @reboot @swap"
    ];
  };

  # Apply a preset at mkOptionDefault priority, so nixpkgs module values win.
  mkDefaults = lib.mapAttrs (_: lib.mkOptionDefault);
}
