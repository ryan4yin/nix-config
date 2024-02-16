{
  # dae(running on aquamarine) do not provides http/socks5 proxy server, so we use v2ray here.
  # https://github.com/v2fly
  services.v2ray = {
    enable = true;
    config = {
      inbounds = [
        {
          listen = "0.0.0.0";
          port = 7890;
          protocol = "http";
        }
        {
          listen = "0.0.0.0";
          port = 7891;
          protocol = "socks";
          settings = {
            auth = "noauth";
            udp = true;
          };
        }
      ];
      outbounds = [
        {
          protocol = "freedom";
          tag = "freedom";
        }
      ];
    };
  };
}
