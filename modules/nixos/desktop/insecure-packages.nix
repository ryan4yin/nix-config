{
  nixpkgs.config.permittedInsecurePackages = [
    # required by wechat-uos:
    # "openssl-1.1.1w"
  ];
}
