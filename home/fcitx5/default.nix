{pkgs, config, lib, ... }: {

  home.file.".config/fcitx5/profile".source = ./profile;
  home.file.".config/fcitx5/profile-bak".source = ./profile;  # used for backup
  # fcitx5 每次切换输入法，就会修改 ~/.config/fcitx5/profile 文件，导致我用 hm 管理的配置被覆盖
  # 解决方法是通过如下内置，每次 rebuild 前都先删除下 profile 文件
  home.activation.removeExistingFcitx5Profile = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    rm -f "${config.xdg.configHome}/fcitx5/profile"
  '';

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
        # for flypy chinese input method
        fcitx5-rime
        # needed enable rime using configtool after installed
        fcitx5-configtool
        fcitx5-chinese-addons
        # fcitx5-mozc    # japanese input method
        fcitx5-gtk     # gtk im module
      ];
  };

  systemd.user.sessionVariables = {
    # copy from  https://github.com/nix-community/home-manager/blob/master/modules/i18n/input-method/fcitx5.nix
    GLFW_IM_MODULE = "fcitx";
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    INPUT_METHOD = "fcitx";
    IMSETTINGS_MODULE  = "fcitx";
    
  };
}