{
  pkgs,
  nur-ryan4yin,
  ...
}: {
  home.file.".local/share/fcitx5/themes".source = "${nur-ryan4yin.packages.${pkgs.system}.catppuccin-fcitx5}/src";

  xdg.configFile = {
    "fcitx5/profile" = {
      source = ./profile;
      # every time fcitx5 switch input method, it will modify ~/.config/fcitx5/profile,
      # so we need to force replace it in every rebuild to avoid file conflict.
      force = true;
    };
    "fcitx5/conf/classicui.conf".source = ./classicui.conf;
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      # for flypy chinese input method
      fcitx5-rime
      # needed enable rime using configtool after installed
      fcitx5-configtool
      fcitx5-chinese-addons
      # fcitx5-mozc    # japanese input method
      fcitx5-gtk # gtk im module
    ];
  };
}
