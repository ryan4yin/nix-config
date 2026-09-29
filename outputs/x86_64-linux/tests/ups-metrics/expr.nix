{
  lib,
  outputs,
  ...
}:
let
  # The UPS moved to youko with the SSD swap; the NUT daemons, the exporter, and
  # the victoriametrics scrape job now all live on the same host.
  youko = outputs.nixosConfigurations.youko.config;
  ups = youko.power.ups.ups.homelab or { };
  exporter = youko.services.prometheus.exporters.nut;
  exporterService =
    youko.systemd.services.prometheus-nut-exporter or {
      after = [ ];
      requires = [ ];
    };
  scrapeJobs = builtins.filter (
    job: (job.job_name or "") == "nut-exporter-homelab-ups"
  ) youko.services.victoriametrics.prometheusConfig.scrape_configs;
  scrapeJob = if builtins.length scrapeJobs == 1 then builtins.head scrapeJobs else null;
in
{
  nut = {
    enable = youko.power.ups.enable;
    mode = youko.power.ups.mode;
    upsmonEnable = youko.power.ups.upsmon.enable;
    killPowerEnable = youko.systemd.services.ups-killpower.enable or false;
    upsdListen = youko.power.ups.upsd.listen;
    driver = ups.driver or null;
    port = ups.port or null;
    vendorId = builtins.elem "vendorid = 0665" (ups.directives or [ ]);
    productId = builtins.elem "productid = 5161" (ups.directives or [ ]);
  };

  exporter = {
    enable = exporter.enable;
    listenAddress = exporter.listenAddress;
    port = exporter.port;
    nutServer = exporter.nutServer;
    exportsAllNumericVariables = builtins.elem "--nut.vars_enable=" exporter.extraFlags;
    startsAfterNut =
      builtins.elem "upsd.service" exporterService.after
      && builtins.elem "upsdrv.service" exporterService.after;
    requiresNut =
      builtins.elem "upsd.service" exporterService.requires
      && builtins.elem "upsdrv.service" exporterService.requires;
  };

  victoriametricsJobCount = builtins.length scrapeJobs;
  victoriametrics =
    if scrapeJob == null then
      null
    else
      {
        inherit (scrapeJob)
          job_name
          scrape_interval
          metrics_path
          params
          ;
        target = builtins.head (builtins.head scrapeJob.static_configs).targets;
        labels = (builtins.head scrapeJob.static_configs).labels;
      };
}
