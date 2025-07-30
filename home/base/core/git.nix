{
  config,
  lib,
  pkgs,
  myvars,
  ...
}:
{
  # `programs.git` will generate the config file: ~/.config/git/config
  # to make git use this config file, `~/.gitconfig` should not exist!
  #
  #    https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    rm -f ${config.home.homeDirectory}/.gitconfig
  '';

  # GitHub CLI tool
  # https://cli.github.com/manual/
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
    hosts = {
      "github.com" = {
        "users" = {
          "ryan4yin" = null;
        };
        "user" = "ryan4yin";
      };
    };
  };

  programs.git = {
    enable = true;
    lfs.enable = true;

    userName = myvars.userfullname;
    userEmail = myvars.useremail;

    includes = [
      {
        # use different email & name for work
        path = "~/work/.gitconfig";
        condition = "gitdir:~/work/";
      }
    ];

    extraConfig = {
      init.defaultBranch = "main";
      trim.bases = "develop,master,main"; # for git-trim
      push.autoSetupRemote = true;
      pull.rebase = true;
      log.date = "iso"; # use iso format for date

      # replace https with ssh
      url = {
        "ssh://git@github.com/ryan4yin" = {
          insteadOf = "https://github.com/ryan4yin";
        };
        # "ssh://git@gitlab.com/" = {
        #   insteadOf = "https://gitlab.com/";
        # };
        # "ssh://git@bitbucket.com/" = {
        #   insteadOf = "https://bitbucket.com/";
        # };
      };
    };

    # signing = {
    #   key = "xxx";
    #   signByDefault = true;
    # };

    # A syntax-highlighting pager for git, diff, grep, and blame output
    delta = {
      enable = true;
      options = {
        diff-so-fancy = true;
        line-numbers = true;
        true-color = "always";
        # features => named groups of settings, used to keep related settings organized
        # features = "";
      };
    };

    aliases = {
      # common aliases
      br = "branch";
      co = "checkout";
      st = "status";
      ls = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate";
      ll = "log --pretty=format:\"%C(yellow)%h%Cred%d\\\\ %Creset%s%Cblue\\\\ [%cn]\" --decorate --numstat";
      cm = "commit -m"; # commit via `git cm <message>`
      ca = "commit -am"; # commit all changes via `git ca <message>`
      dc = "diff --cached";

      amend = "commit --amend -m"; # amend commit message via `git amend <message>`
      unstage = "reset HEAD --"; # unstage file via `git unstage <file>`
      merged = "branch --merged"; # list merged(into HEAD) branches via `git merged`
      unmerged = "branch --no-merged"; # list unmerged(into HEAD) branches via `git unmerged`
      nonexist = "remote prune origin --dry-run"; # list non-exist(remote) branches via `git nonexist`

      # delete merged branches except master & dev & staging
      #  `!` indicates it's a shell script, not a git subcommand
      delmerged = ''! git branch --merged | egrep -v "(^\*|main|master|dev|staging)" | xargs git branch -d'';
      # delete non-exist(remote) branches
      delnonexist = "remote prune origin";

      # aliases for submodule
      update = "submodule update --init --recursive";
      foreach = "submodule foreach";
    };
  };

  # Git terminal UI (written in go).
  programs.lazygit.enable = true;

  # Yet another Git TUI (written in rust).
  programs.gitui.enable = true;
}
