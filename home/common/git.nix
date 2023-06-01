{
  pkgs,
  ...
}: {
  programs.git = {
    enable = true;
    lfs.enable = true;

    userName = "Ryan Yin";
    userEmail = "xiaoyin_c@qq.com";

    includes = [
      {
        # use diffrent email & name for work
        path = "~/mobiuspace/.gitconfig";
        condition = "gitdir:~/mobiuspace/";
      }
    ];

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