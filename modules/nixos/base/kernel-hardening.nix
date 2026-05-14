{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Kernel module blacklisting to mitigate Dirty Frag LPE (Local Privilege Escalation) vulnerabilities.
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
