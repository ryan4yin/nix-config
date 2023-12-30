# ==============================================
# Based on doomemacs's auther's config:
#   https://github.com/hlissner/dotfiles/blob/master/modules/editors/emacs.nix
#
# Emacs Tutorials:
#  1. Official: <https://www.gnu.org/software/emacs/tour/index.html>
#  2. Doom Emacs: <https://github.com/doomemacs/doomemacs/blob/master/docs/index.org> 
#
{
  config,
  lib,
  pkgs,
  doomemacs,
  ...
}:
with lib; let
  cfg = config.modules.editors.emacs;
  envExtra = ''
    export PATH="$XDG_CONFIG_HOME/emacs/bin:$PATH"
  '';
in {
  options.modules.editors.emacs = {
    enable = mkEnableOption "Emacs Editor";
    doom = {
      enable = mkEnableOption "Doom Emacs";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ## Emacs itself
      binutils # native-comp needs 'as', provided by this
      # 28.2 + native-comp
      ((emacsPackagesFor emacs-unstable-nox).emacsWithPackages
        (epkgs: [epkgs.vterm]))
      emacs-all-the-icons-fonts

      ## Doom dependencies
      git
      (ripgrep.override {withPCRE2 = true;})
      gnutls # for TLS connectivity

      ## Optional dependencies
      fd # faster projectile indexing
      imagemagick # for image-dired
      zstd # for undo-fu-session/undo-tree compression

      ## Module dependencies
      # :checkers spell
      (aspellWithDicts (ds: with ds; [en en-computers en-science]))
      # :tools editorconfig
      editorconfig-core-c # per-project style config
      # :tools lookup & :lang org +roam
      sqlite
      # :lang latex & :lang org (latex previews)
      texlive.combined.scheme-medium
    ];

    programs.bash.bashrcExtra = envExtra;
    programs.zsh.envExtra = envExtra;
    # allow fontconfig to discover fonts and configurations installed through `home.packages`
    fonts.fontconfig.enable = true;

    xdg.configFile."doom".source = ./doom;

    home.activation = mkIf cfg.doom.enable {
      installDoomEmacs = lib.hm.dag.entryAfter ["writeBoundary"] ''
        ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F744 ${doomemacs}/ ${config.xdg.configHome}/emacs/
      '';
    };
  };
}
