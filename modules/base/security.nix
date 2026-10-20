{
  # Add my private PKI's CA certificate to the system-wide trust store.
  security.pki.certificateFiles = [
    ../../certs/ecc-ca.crt
  ];

  # Distrust the roots that signed the compromised eMudhra intermediates
  # (Mozilla advisory, 2026-10-20). Upstream nixpkgs blacklists them as of
  # NixOS/nixpkgs#576390; drop this once every consumed nixpkgs revision has it (WA-040).
  security.pki.caCertificateBlacklist = [
    "Comodo AAA Services root"
    "emSign ECC Root CA - G3"
    "emSign Root CA - C1"
    "emSign ECC Root CA - C3"
  ];
}
