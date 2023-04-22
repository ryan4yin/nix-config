{
  pkgs,
  ...
}: {
  home.packages = [pkgs.gh];

  programs.git = {
    enable = true;

    userName = "Ryan Yin";
    userEmail = "xiaoyin_c@qq.com";
  };
}