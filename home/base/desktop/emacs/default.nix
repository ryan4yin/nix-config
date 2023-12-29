{
  pkgs,
  config,
  lib,
  nix-doom-emacs,
  ...
}:
with lib; let
  cfg = config.modules.desktop.emacs;
in {
  imports = [nix-doom-emacs.hmModule];

  options.modules.desktop.emacs = {
    enable = mkEnableOption "Emacs Editor";
  };

  config = mkIf cfg.enable {
    programs.doom-emacs = {
      enable = true;
      # Directory containing your config.el, init.el and packages.el files
      doomPrivateDir = ./doom.d;
      emacsPackage = pkgs.emacs-nox;
    };
  };
}
