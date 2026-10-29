{
  # Add my private PKI's CA certificate to the system-wide trust store.
  security.pki.certificateFiles = [
    ../../certs/ecc-ca.crt
  ];

  # CVE-2026-111943. NixOS adds this entry itself, but nix-darwin only passes
  # this list through, so keep it explicit for both platforms. The emSign roots
  # are gone from the NSS bundle upstream; listing those names now makes
  # buildcatrust fail, so they are intentionally absent.
  security.pki.caCertificateBlacklist = [
    "Comodo AAA Services root"
  ];
}
