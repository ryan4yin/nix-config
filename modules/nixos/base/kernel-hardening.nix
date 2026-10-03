{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Kernel module blacklisting to mitigate the Dirty Frag LPE (CVE-2026-43284 /
  # CVE-2026-43500). None of these modules are used here; re-evaluate (drop the
  # blacklist) once the pinned kernel carries the upstream fix.
  boot.blacklistedKernelModules = [
    "esp4"
    "esp6"
    "rxrpc"
  ];

  boot.extraModprobeConfig = ''
    install esp4 ${pkgs.coreutils}/bin/false
    install esp6 ${pkgs.coreutils}/bin/false
    install rxrpc ${pkgs.coreutils}/bin/false
  '';
}
