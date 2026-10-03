{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Blacklist unused kernel modules to shrink the attack surface. esp4/esp6/rxrpc
  # were the vectors for the Dirty Frag LPE (CVE-2026-43284 / CVE-2026-43500);
  # kept as defence in depth even though the upstream fix has long landed, since
  # nothing here uses them.
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
