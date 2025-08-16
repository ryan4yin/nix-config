{
  # systemd-journal - reduce disk usage
  # https://www.freedesktop.org/software/systemd/man/latest/journald.conf.html
  services.journald.extraConfig = ''
    SystemMaxUse=2G
    RuntimeMaxUse=256M
  '';
}
