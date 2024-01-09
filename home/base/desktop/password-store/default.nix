{pkgs, config, ...}: { 
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
      PASSWORD_STORE_CLIP_TIME = "60";
      PASSWORD_STORE_GENERATED_LENGTH = "15";
      PASSWORD_STORE_ENABLE_EXTENSIONS = "true";
    };
  };
}
