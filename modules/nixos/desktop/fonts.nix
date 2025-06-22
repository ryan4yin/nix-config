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

      # nerdfonts
      # https://github.com/NixOS/nixpkgs/blob/nixos-unstable-small/pkgs/data/fonts/nerd-fonts/manifests/fonts.json
      nerd-fonts.symbols-only # symbols icon only
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.iosevka

      # Noto 是 Google 开发的开源字体家族
      # 名字的含义是「没有豆腐」（no tofu），因为缺字时显示的方框或者方框被叫作 tofu
      #
      # Noto 系列字族只支持西文，命名规则是 Noto + Sans 或 Serif + 文字名称。
      noto-fonts # 大部分文字的常见样式，不包含汉字
      noto-fonts-color-emoji # 彩色的表情符号字体
      # Noto CJK 为「思源」系列汉字字体，由 Adobe + Google 共同开发
      # Google 以 Noto Sans/Serif CJK SC/TC/HK/JP/KR 的名称发布该系列字体。
      # 这俩跟 noto-fonts-cjk-sans/serif 实际为同一字体，只是分别由 Adobe/Google 以自己的品牌名发布
      # noto-fonts-cjk-sans # 思源黑体
      # noto-fonts-cjk-serif # 思源宋体

      # Adobe 以 Source Han Sans/Serif 的名称发布此系列字体
      source-sans # 无衬线字体，不含汉字。字族名叫 Source Sans 3，以及带字重的变体（VF）
      source-serif # 衬线字体，不含汉字。字族名叫 Source Serif 4，以及带字重的变体
      # Source Hans 系列汉字字体由 Adobe + Google 共同开发
      source-han-sans # 思源黑体
      source-han-serif # 思源宋体
      source-han-mono # 思源等宽

      # 霞鹜文楷屏幕阅读版
      # https://github.com/lxgw/LxgwWenKai-Screen
      lxgw-wenkai-screen

      # Maple Mono NF CN (连字 未微调版，适用于高分辨率屏幕)
      # Full version, embed with nerdfonts icons, Chinese and Japanese glyphs
      # https://github.com/subframe7536/maple-font
      maple-mono.NF-CN-unhinted
    ];

    fontconfig = {
      # User defined default fonts
      # https://catcat.cc/post/2021-03-07/
      defaultFonts = {
        serif = [
          # 西文: 衬线字体（笔画末端有修饰(衬线)的字体，通常用于印刷。）
          "Source Sans 3"
          # 中文: 宋体（港台称明體）
          "Source Han Serif SC" # 思源宋体
          "Source Han Serif TC"
        ];
        # SansSerif 也简写做 Sans, Sans 在法语中就是「without」或者「无」的意思
        sansSerif = [
          # 西文: 无衬线字体（指笔画末端没有修饰(衬线)的字体，通常用于屏幕显示）
          "Source Serif 4"
          # 中文: 黑体
          "LXGW WenKai Screen" # 霞鹜文楷 屏幕阅读版
          "Source Han Sans SC" # 思源黑体
          "Source Han Sans TC"
        ];
        # 等宽字体
        monospace = [
          # 中文
          "Maple Mono NF CN" # 中英文宽度完美 2:1 的字体
          "Source Han Mono SC" # 思源等宽
          "Source Han Mono TC"
          # 西文
          "JetBrainsMono Nerd Font"
        ];
        emoji = ["Noto Color Emoji"];
      };
      antialias = true; # 抗锯齿
      hinting.enable = false; # 禁止字体微调 - 高分辨率下没这必要
      subpixel = {
        rgba = "rgb"; # IPS 屏幕使用 rgb 排列
      };
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
        name = "Maple Mono NF CN";
        package = maple-mono.NF-CN-unhinted;
      }
      {
        name = "JetBrainsMono Nerd Font";
        package = nerd-fonts.jetbrains-mono;
      }
    ];
    extraOptions = "--term xterm-256color";
    extraConfig = "font-size=14";
    # Whether to use 3D hardware acceleration to render the console.
    hwRender = true;
  };
}
