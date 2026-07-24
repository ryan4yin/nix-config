{ myvars, ... }:
let
  hostAddress = myvars.networking.hostsAddr.kubevirt-shushou.ipv4;
in
{
  power.ups = {
    enable = true;
    mode = "standalone";

    # Metrics only. Coordinated shutdown of all homelab hosts is a separate feature.
    upsmon = {
      enable = false;
      settings.POWERDOWNFLAG = null;
    };

    upsd.listen = [
      {
        address = "127.0.0.1";
        port = 3493;
      }
    ];

    ups.homelab = {
      driver = "nutdrv_qx";
      port = "auto";
      description = "Homelab UPS";
      directives = [
        "vendorid = 0665"
        "productid = 5161"
      ];
    };
  };

  services.prometheus.exporters.nut = {
    enable = true;
    listenAddress = hostAddress;
    port = 9199;
    nutServer = "127.0.0.1";

    # The NixOS module omits --nut.vars_enable when nutVariables is empty, but the exporter needs
    # an explicitly empty value to export every numeric NUT variable.
    extraFlags = [ "--nut.vars_enable=" ];
  };

  systemd.services.prometheus-nut-exporter = {
    after = [
      "upsd.service"
      "upsdrv.service"
    ];
  };
}
