{
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    lfs.enable = true;

    userName = "Ryan Yin";
    userEmail = "xiaoyin_c@qq.com";

    extraConfig = {
      pull = {
        rebase = true;
      };
    };

    # signing = {
    #   key = "xxx";
    #   signByDefault = true;
    # };

    delta = {
      enable = true;
      options = {
        features = "side-by-side";
      };
    };
  };
}