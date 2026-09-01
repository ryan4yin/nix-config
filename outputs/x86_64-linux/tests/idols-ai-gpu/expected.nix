{
  dynamicBoost = false;
  loadsVirtualDisplay = true;
  createsVirtualDisplay = true;
  niriUsesIntelRenderer = true;
  sunshine = {
    adapter_name = "/dev/dri/by-path/pci-0000:00:02.0-render";
    encoder = "vaapi";
    libvaDriver = "iHD";
    startsAfterNiri = true;
    waitsForNiriOutput = true;
  };
  forcedNvidiaSessionVariables = {
    GBM_BACKEND = null;
    LIBVA_DRIVER_NAME = null;
    NVD_BACKEND = null;
    __GLX_VENDOR_LIBRARY_NAME = null;
  };
}
