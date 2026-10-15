# OpenRGB has no Colorful motherboard driver, so aquamarine's ARGB header blinks with no way to set
# it. This carries the controller from MR !3543 (`2F4C:1000`, Direct mode only) until upstream
# releases it — see WA-035.
{ ... }:
_final: prev: {
  openrgb = prev.openrgb.overrideAttrs (old: {
    patches = old.patches ++ [
      (prev.fetchpatch {
        url = "https://gitlab.com/CalcProgrammer1/OpenRGB/-/merge_requests/3543.diff";
        hash = "sha256-T3ZuVO2Pui73P7/bUycG89TmD7K3Gv/vedGJXW1FgeU=";
      })
    ];
  });
}
