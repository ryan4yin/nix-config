{
  config,
  pkgs-unstable,
  ...
}:
let
  inherit (pkgs-unstable) nu_scripts;
in
{
  programs.nushell = {
    # load the alias file for work
    # the file must exist, otherwise nushell will complain about it!
    #
    # currently, nushell does not support conditional sourcing of files
    # https://github.com/nushell/nushell/issues/8214
    extraConfig = ''
      source /etc/agenix/alias-for-work.nushell

      # using claude-code with kimi k2
      $env.ANTHROPIC_BASE_URL = "https://api.moonshot.cn/anthropic/"
      $env.ANTHROPIC_API_KEY = $env.MOONSHOT_API_KEY

      # Directories in this constant are searched by the
      # `use` and `source` commands.
      const NU_LIB_DIRS = $NU_LIB_DIRS ++ ['${nu_scripts}/share/nu_scripts']

      # completion
      use custom-completions/cargo/cargo-completions.nu *
      use custom-completions/curl/curl-completions.nu *
      use custom-completions/git/git-completions.nu *
      use custom-completions/glow/glow-completions.nu *
      use custom-completions/just/just-completions.nu *
      use custom-completions/make/make-completions.nu *
      use custom-completions/man/man-completions.nu *
      use custom-completions/nix/nix-completions.nu *
      use custom-completions/ssh/ssh-completions.nu *
      use custom-completions/tar/tar-completions.nu *
      use custom-completions/tcpdump/tcpdump-completions.nu *
      use custom-completions/zellij/zellij-completions.nu *
      # use custom-completions/zoxide/zoxide-completions.nu *

      # alias
      # use aliases/git/git-aliases.nu *
      use aliases/eza/eza-aliases.nu *
      use aliases/bat/bat-aliases.nu *

      # modules
      use modules/argx *
      use modules/lg *
      use modules/kubernetes *
    '';
  };
}
