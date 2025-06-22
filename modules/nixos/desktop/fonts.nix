{pkgs, ...}: {
  # all fonts are linked to /nix/var/nix/profiles/system/sw/share/X11/fonts
  fonts = {
    # use fonts specified by user rather than default ones
    enableDefaultPackages = false;
    fontDir.enable = true;

    packages = with pkgs; [
      # icon fonts
      material-design-icons
      font-awesome

      # Noto 是 Google 开发的开源字体家族
      # 名字的含义是「没有豆腐」（no tofu），因为缺字时显示的方框或者方框被叫作 tofu
      #
      # Noto 系列字族只支持英文，命名规则是 Noto + Sans 或 Serif + 文字名称。
      noto-fonts # 大部分文字的常见样式，不包含汉字
      noto-fonts-color-emoji # 彩色的表情符号字体
      # Noto CJK 为「思源」系列汉字字体，由 Adobe + Google 共同开发
      # Google 以 Noto Sans/Serif CJK SC/TC/HK/JP/KR 的名称发布该系列字体。
      # noto-fonts-cjk-sans # 思源黑体
      # noto-fonts-cjk-serif # 思源宋体

      # Adobe 以 Source Han Sans/Serif 的名称发布此系列字体
      source-sans # 无衬线字体，不含汉字。字族名叫 Source Sans 3，以及带字重的变体（VF）
      source-serif # 衬线字体，不含汉字。字族名叫 Source Serif 4，以及带字重的变体
      # Source Hans 系列汉字字体由 Adobe + Google 共同开发
      # 这俩跟 noto-fonts-cjk-xxx 实际为同一字体，只是分别由 Adobe/Google 以自己的品牌名发布
      source-han-sans # 思源黑体
      source-han-serif # 思源宋体

      # 文泉驿是旅美学者房骞骞（FangQ）于 2004 年创建的开源汉字字体项目
      wqy_zenhei # 文泉驿正黑
      wqy_microhei # 文泉驿微米黑

      # nerdfonts
      # https://github.com/NixOS/nixpkgs/blob/nixos-unstable-small/pkgs/data/fonts/nerd-fonts/manifests/fonts.json
      nerd-fonts.symbols-only # symbols icon only
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka

      julia-mono
    ];

    # User defined default fonts
    fontconfig.defaultFonts = {
      serif = [
        # 英文: 衬线字体
        "Source Sans 3"
        # 中文: 宋体/明体
        "Source Han Serif SC"
        "Source Han Serif TC"
      ];
      # SansSerif 也简写做 Sans, Sans 在法语中就是「without」或者「无」的意思
      sansSerif = [
        # 英文: 无衬线字体
        "Source Serif 4"
        # 中文: 黑体
        "Source Han Sans SC"
        "Source Han Sans TC"
      ];
      # 等宽字体
      monospace = [
        # 英文
        "JetBrainsMono Nerd Font"
        # 中文
        "WenQuanYi Micro Hei Mono"
      ];
      emoji = ["Noto Color Emoji"];
    };
  };

  # https://wiki.archlinux.org/title/KMSCON
  services.kmscon = {
    # Use kmscon as the virtual console instead of gettys.
    # kmscon is a kms/dri-based userspace virtual terminal implementation.
    # It supports a richer feature set than the standard linux console VT,
    # including full unicode support, and when the video card supports drm should be much faster.
    enable = true;
    fonts = with pkgs; [
      {
        name = "Source Code Pro";
        package = source-code-pro;
      }
      # CJK font
      {
        name = "WenQuanYi Micro Hei Mono";
        package = wqy_microhei;
      }
    ];
    extraOptions = "--term xterm-256color";
    extraConfig = "font-size=14";
    # Whether to use 3D hardware acceleration to render the console.
    hwRender = true;
  };
}
