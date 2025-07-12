{
  # replacement of htop/nmon
  programs.btop = {
    enable = true;
    settings = {
      theme_background = false; # make btop transparent
    };
  };
}
