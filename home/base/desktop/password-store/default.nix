{pkgs, config, lib, ...}: { 
  programs.password-store = {
    enable = true;
    package = pkgs.pass.withExtensions (exts: [
      # support for one-time-password (OTP) tokens
      # NOTE: Saving the password and OTP together runs counter to the purpose of secondary verification!
      # exts.pass-otp

      exts.pass-import # a generic importer tool from other password managers
      exts.pass-update # an easy flow for updating passwords
    ]);
    # See the “Environment variables” section of pass(1) and the extension man pages for more information about the available keys.
    settings = {
      PASSWORD_STORE_DIR = "${config.xdg.dataHome}/password-store";
      # Overrides the default gpg key identification set by init. 
      # Hexadecimal key signature is recommended.
      # Multiple keys may be specified separated by spaces.
      PASSWORD_STORE_KEY = lib.strings.concatStringsSep " " [
        "62526A4A0CF43E33"  # E - Ryan Yin (Personal) <ryan4yin@linux.com>
      ];
      # all .gpg-id files and non-system extension files must be signed using a detached signature using the GPG key specified by
      #   the full 40 character upper-case fingerprint in this variable.
      # If multiple fingerprints are specified, each separated by a whitespace character, then signatures must match at least one. 
      # The init command will keep signatures of .gpg-id files up to date.
      PASSWORD_STORE_SIGNING_KEY = lib.strings.concatStringsSep " " [
        "433A66D63805BD1A" # S - Ryan Yin (Personal) <ryan4yin@linux.com>
      ];
      PASSWORD_STORE_CLIP_TIME = "60";
      PASSWORD_STORE_GENERATED_LENGTH = "15";
      PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
    };
  };
}