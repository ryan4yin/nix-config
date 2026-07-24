{
  nut = {
    enable = true;
    mode = "standalone";
    upsmonEnable = false;
    killPowerEnable = false;
    upsdListen = [
      {
        address = "127.0.0.1";
        port = 3493;
      }
    ];
    driver = "nutdrv_qx";
    port = "auto";
    vendorId = true;
    productId = true;
  };

  exporter = {
    enable = true;
    listenAddress = "192.168.5.182";
    port = 9199;
    nutServer = "127.0.0.1";
    exportsAllNumericVariables = true;
    startsAfterNut = true;
    requiresNut = false;
  };

  victoriametricsJobCount = 1;
  victoriametrics = {
    job_name = "nut-exporter-homelab-ups";
    scrape_interval = "30s";
    metrics_path = "/ups_metrics";
    params.ups = [ "homelab" ];
    target = "192.168.5.182:9199";
    labels = {
      type = "app";
      app = "nut";
      host = "kubevirt-shushou";
      env = "homelab";
      cluster = "homelab";
    };
  };
}
