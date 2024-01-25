_: {
  # use mirror for pip install
  xdg.configFile."pip/pip.conf".text = ''
    [global]
    index-url = https://mirrors.bfsu.edu.cn/pypi/web/simple
  '';
}
