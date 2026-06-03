_: {
  # use pypi mirror
  # filter packages via upload time for supply-chain security
  xdg.configFile."pip/pip.conf".text = ''
    [global]
    index-url = https://mirrors.bfsu.edu.cn/pypi/web/simple

    [install]
    uploaded-prior-to = P2D
  '';
  xdg.configFile."uv/uv.toml".text = ''
    exclude-newer = "2 days"
  '';
}
