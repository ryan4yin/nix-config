{pkgs, config, ...}: {
  programs.gpg = {
    enable = true;
    homedir = "${config.home.homeDirectory}/.gnupg";
    #  $GNUPGHOME/trustdb.gpg stores all the trust level you specified in `programs.gpg.publicKeys` option.
    # 
    # If set `mutableTrust` to false, the path $GNUPGHOME/trustdb.gpg will be overwritten on each activation.
    # Thus we can only update trsutedb.gpg via home-manager.
    mutableTrust = true;

    # $GNUPGHOME/pubring.kbx stores all the public keys you specified in `programs.gpg.publicKeys` option.
    #  
    # If set `mutableKeys` to false, the path $GNUPGHOME/pubring.kbx will become an immutable link to the Nix store, denying modifications.
    # Thus we can only update pubring.kbx via home-manager
    mutableKeys = true;
    publicKeys = [
      # https://www.gnupg.org/gph/en/manual/x334.html
      # { source = ./xxx.key, trust = 3}
    ];
    settings = {
      
    };
  };
}
