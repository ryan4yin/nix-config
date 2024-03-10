{lib}: {
  username = "ryan";
  userfullname = "Ryan Yin";
  useremail = "xiaoyin_c@qq.com";
  networking = import ./networking.nix {inherit lib;};
}
