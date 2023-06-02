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

      # replace https with ssh
      url = {
        "ssh://git@github.com/" = {
          insteadOf = "https://github.com/";
        };
        "ssh://git@gitlab.com/" = {
          insteadOf = "https://gitlab.com/";
        };
        "ssh://git@bitbucket.com/" = {
          insteadOf = "https://bitbucket.com/";
        };
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