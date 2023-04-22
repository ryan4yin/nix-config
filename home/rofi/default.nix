{
  pkgs,
  config,
  ...
}: {
  # 基于 https://github.com/endeavouros-team/endeavouros-i3wm-setup
  # 直接从当前文件夹中读取配置文件作为配置内容
  home.file.".config/rofi" = {
    source = ./configs;
    # copy the scripts directory recursively
    recursive = true;
  };

  # 直接以 text 的方式，在 nix 配置文件中硬编码文件内容
  # home.file.".xxx".text = ''
  #     xxx
  # '';
}