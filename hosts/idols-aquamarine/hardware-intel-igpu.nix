{
  pkgs,
  ...
}:

# ===============================================================================================
# Intel Arrow Lake-S iGPU (i915). The R9700s are reserved for model inference, so the iGPU takes
# video work and small OpenVINO jobs: iHD backs VA-API, oneVPL/QSV is Intel's video API, and
# intel-compute-runtime provides the OpenCL/Level Zero devices OpenVINO's GPU plugin needs.
# ===============================================================================================
{
  hardware.graphics.extraPackages = with pkgs; [
    intel-media-driver
    vpl-gpu-rt
    intel-compute-runtime
  ];
}
