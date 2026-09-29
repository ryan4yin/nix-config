{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.btop;
in
{
  options.modules.btop = {
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.btop;
      defaultText = lib.literalExpression "pkgs.btop";
      description = ''
        btop build to install. The per-vendor GPU modules set this to
        `btop-cuda`/`btop-rocm`, whose RUNPATH includes the vendor library that
        btop otherwise cannot find (and Intel needs no library, only perf
        access, see `perfmon`).
      '';
    };
    perfmon = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Install btop as a `CAP_PERFMON` wrapper so it can read Intel GPU stats
        without lowering `kernel.perf_event_paranoid` system-wide.
      '';
    };
  };

  config = {
    # Exactly one btop per host: a plain package normally, or the capability
    # wrapper only when `perfmon` is set. Home Manager skips its own copy on
    # NixOS (see home/base/core/btop.nix).
    environment.systemPackages = lib.optional (!cfg.perfmon) cfg.package;

    # perf_event_paranoid stays at its default; only the wrapper gets the
    # capability, and exactly one `btop` remains on PATH (/run/wrappers/bin).
    security.wrappers = lib.mkIf cfg.perfmon {
      btop = {
        source = "${cfg.package}/bin/btop";
        owner = "root";
        group = "root";
        capabilities = "cap_perfmon+ep";
      };
    };
  };
}
