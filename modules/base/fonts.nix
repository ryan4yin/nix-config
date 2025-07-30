{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.desktop;
in
{
  options.modules.desktop = {
    fonts.enable = lib.mkEnableOption "Rich Fonts - Add NerdFonts Icons, emojis & CJK Fonts";
  };

  config.fonts.packages =
    with pkgs;
    lib.mkIf cfg.fonts.enable [
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

      # 霞鹜文楷 屏幕阅读版
      # https://github.com/lxgw/LxgwWenKai-Screen
      lxgw-wenkai-screen

      # Maple Mono NF CN (连字 未微调版，适用于高分辨率屏幕)
      # Full version, embed with nerdfonts icons, Chinese and Japanese glyphs
      # https://github.com/subframe7536/maple-font
      maple-mono.NF-CN-unhinted
    ];
}
