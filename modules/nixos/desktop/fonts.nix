{ pkgs, ... }:
{
  # all fonts are linked to /nix/var/nix/profiles/system/sw/share/X11/fonts
  fonts = {
    # use fonts specified by user rather than default ones
    enableDefaultPackages = false;
    fontDir.enable = true;

    # fonts are defined in /modules/base/fonts.nix, used by both NixOS & Darwin.
    # packages = [ ... ];

    fontconfig = {
      # User defined default fonts. Nixpak GUI wrappers bind this generated
      # host configuration into their sandboxes, so host and sandboxed apps
      # share one font stack; do not duplicate these families there.
      # https://catcat.cc/post/2021-03-07/
      defaultFonts = {
        serif = [
          # 西文: 衬线字体（笔画末端有修饰(衬线)的字体，通常用于印刷。）
          "Source Serif 4"
          # 中文: 宋体（港台称明體）
          "Noto Serif CJK SC" # 思源宋体
          "Noto Serif CJK TC"
          # 日文、韩文回退
          "Noto Serif CJK JP"
          "Noto Serif CJK KR"
        ];
        # SansSerif 也简写做 Sans, Sans 在法语中就是「without」或者「无」的意思
        sansSerif = [
          # 西文: 无衬线字体（指笔画末端没有修饰(衬线)的字体，通常用于屏幕显示）
          "Source Sans 3"
          # 中文: 黑体
          "LXGW WenKai Screen" # 霞鹜文楷 屏幕阅读版
          "Noto Sans CJK SC" # 思源黑体
          "Noto Sans CJK TC"
          # 日文、韩文回退
          "Noto Sans CJK JP"
          "Noto Sans CJK KR"
        ];
        # 等宽字体
        monospace = [
          # 中文
          "Maple Mono NF CN" # 中英文宽度完美 2:1 的字体
          "Noto Sans Mono CJK SC" # 思源等宽
          "Noto Sans Mono CJK TC"
          # 日文、韩文回退
          "Noto Sans Mono CJK JP"
          "Noto Sans Mono CJK KR"
          # 西文
          "JetBrainsMono Nerd Font"
        ];
        emoji = [ "Noto Color Emoji" ];
      };
      # 日文、韩文环境优先使用对应字形；中文环境仍使用上面的 SC 默认栈。
      localConf =
        let
          langFonts = lang: sans: serif: monospace: ''
            <match target="pattern">
              <test name="lang" compare="contains"><string>${lang}</string></test>
              <test name="family" qual="any"><string>sans-serif</string></test>
              <edit name="family" mode="assign" binding="strong">
                <string>Source Sans 3</string>
                <string>${sans}</string>
                <string>Noto Sans CJK SC</string>
              </edit>
            </match>
            <match target="pattern">
              <test name="lang" compare="contains"><string>${lang}</string></test>
              <test name="family" qual="any"><string>serif</string></test>
              <edit name="family" mode="assign" binding="strong">
                <string>Source Serif 4</string>
                <string>${serif}</string>
                <string>Noto Serif CJK SC</string>
              </edit>
            </match>
            <match target="pattern">
              <test name="lang" compare="contains"><string>${lang}</string></test>
              <test name="family" qual="any"><string>monospace</string></test>
              <edit name="family" mode="assign" binding="strong">
                <string>JetBrainsMono Nerd Font</string>
                <string>${monospace}</string>
                <string>Noto Sans Mono CJK SC</string>
              </edit>
            </match>
          '';
        in
        ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
          <fontconfig>
            <!-- generic family 在 51-local 阶段仍是 sans-serif。 -->
            ${langFonts "ja" "Noto Sans CJK JP" "Noto Serif CJK JP" "Noto Sans Mono CJK JP"}
            ${langFonts "ko" "Noto Sans CJK KR" "Noto Serif CJK KR" "Noto Sans Mono CJK KR"}
          </fontconfig>
        '';
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
    extraOptions = "--term xterm-256color";
    config = {
      font-name = "Maple Mono NF CN";
      font-size = 14;
      hwaccel = true;
    };
  };
}
