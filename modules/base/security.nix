{
  lib,
  pkgs,
  ...
}:
{
  # Add my private PKI's CA certificate to the system-wide trust store.
  security.pki.certificateFiles = [
    ../../certs/ecc-ca.crt
  ];

  # Distrust the roots that signed the compromised eMudhra intermediates
  # (Mozilla advisory, 2026-10-20). The emSign roots have already been removed
  # from the NSS cert store in the main nixpkgs input; listing them there makes
  # buildcatrust fail because a blocklist entry is no longer present. Keep those
  # entries only for nixpkgs-darwin, which still carries the older bundle.
  security.pki.caCertificateBlacklist = [
    "Comodo AAA Services root"
  ]
  ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    "emSign ECC Root CA - G3"
    "emSign Root CA - C1"
    "emSign ECC Root CA - C3"
  ];
}
