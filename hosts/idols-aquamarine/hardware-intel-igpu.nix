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

  # OpenVINO's GPU plugin links the OpenCL 3.0 loader (ocl-icd), but
  # `/run/opengl-driver/lib/libOpenCL.so.1` comes from ROCm's clr (OpenCL 2.2), so the plugin
  # fails to load and OpenVINO silently drops GPU from `available_devices`. Run OpenVINO jobs
  # through this wrapper to put ocl-icd first and pin the Intel ICD (WORKAROUNDS.md, WA-038).
  # See IGPU.md for running models on the iGPU.
  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "openvino-gpu";
      text = ''
        export LD_LIBRARY_PATH="${pkgs.ocl-icd}/lib''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
        export OCL_ICD_VENDORS="${pkgs.intel-compute-runtime}/etc/OpenCL/vendors"
        exec "$@"
      '';
    })
  ];
}
