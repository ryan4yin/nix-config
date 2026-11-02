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

  # This is the single font package list for the host and its Nixpak sandboxes:
  # Nixpak GUI wrappers bind the generated host fontconfig rather than
  # installing their own fonts.
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
      # Noto 系列字族覆盖西文与其他文字；noto-fonts 本身不含汉字。
      noto-fonts # 大部分文字的常见样式，不包含汉字
      noto-fonts-color-emoji # 彩色的表情符号字体
      # Noto CJK 与 Adobe 的 Source Han 系列是同一套字形，区别只在发行名称。
      # Noto 在 Linux 生态中更常见，也是更多应用直接请求的字体族名称；
      # 因此这里优先安装 Noto CJK，而不是 Source Han。
      noto-fonts-cjk-sans # Noto Sans CJK / Noto Sans Mono CJK
      noto-fonts-cjk-serif # Noto Serif CJK

      source-sans # 无衬线字体，不含汉字。字族名叫 Source Sans 3，以及带字重的变体（VF）
      source-serif # 衬线字体，不含汉字。字族名叫 Source Serif 4，以及带字重的变体（VF）

      # 霞鹜文楷 屏幕阅读版
      # https://github.com/lxgw/LxgwWenKai-Screen
      lxgw-wenkai-screen

      # Maple Mono NF CN (连字 未微调版，适用于高分辨率屏幕)
      # Full version, embed with nerdfonts icons, Chinese and Japanese glyphs
      # https://github.com/subframe7536/maple-font
      maple-mono.NF-CN-unhinted
    ];
}
