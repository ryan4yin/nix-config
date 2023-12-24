{
  pkgs,
  config,
  lib,
  ...
}: let
  t2Cfg = config.hardware.myapple-t2;
  efiPrefix = config.boot.loader.efi.efiSysMountPoint;

  apple-set-os-loader-installer = pkgs.stdenv.mkDerivation rec {
    name = "apple-set-os-loader-installer-1.0";
    src = pkgs.fetchFromGitHub {
      owner = "Redecorating";
      repo = "apple_set_os-loader";
      rev = "r33.9856dc4";
      sha256 = "hvwqfoF989PfDRrwU0BMi69nFjPeOmSaD6vR6jIRK2Y=";
    };
    buildInputs = [pkgs.gnu-efi];
    buildPhase = ''
      substituteInPlace Makefile --replace "/usr" '$(GNU_EFI)'
      export GNU_EFI=${pkgs.gnu-efi}
      make
    '';
    installPhase = ''
      install -D bootx64_silent.efi $out/bootx64.efi
    '';
  };
in {
  options = {
    hardware.myapple-t2.enableAppleSetOsLoader = lib.mkOption {
      default = false;
      type = lib.types.bool;
      description = "Whether to enable the appleSetOsLoader activation script.";
    };
  };

  config = {
    # Activation script to install apple-set-os-loader in order to unlock the iGPU
    system.activationScripts.myappleSetOsLoader = lib.optionalString t2Cfg.enableAppleSetOsLoader ''
      if [[ -e ${efiPrefix}/efi/boot/bootx64_original.efi ]]; then
        true # It's already installed, no action required
      elif [[ -e ${efiPrefix}/efi/boot/bootx64.efi ]]; then
        # Copy the new bootloader to a temporary location
        cp ${apple-set-os-loader-installer}/bootx64.efi ${efiPrefix}/efi/boot/bootx64_temp.efi

        # Rename the original bootloader
        mv ${efiPrefix}/efi/boot/bootx64.efi ${efiPrefix}/efi/boot/bootx64_original.efi

        # Move the new bootloader to the final destination
        mv ${efiPrefix}/efi/boot/bootx64_temp.efi ${efiPrefix}/efi/boot/bootx64.efi
      else
        echo "Error: ${efiPrefix}/efi/boot/bootx64.efi is missing" >&2
      fi
    '';

    # Enable the iGPU by default if present
    environment.etc."modprobe.d/apple-gmux.conf".text = lib.optionalString t2Cfg.enableAppleSetOsLoader ''
      options apple-gmux force_igd=y
    '';
  };
}
