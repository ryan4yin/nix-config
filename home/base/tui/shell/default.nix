{
  nu_scripts,
  ...
}:
{
  programs.nushell = {
    # load the alias file for work
    # the file must exist, otherwise nushell will complain about it!
    #
    # currently, nushell does not support conditional sourcing of files
    # https://github.com/nushell/nushell/issues/8214
    extraConfig = ''
      source /etc/agenix/alias-for-work.nushell

      $env.CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC = "1"
      $env.CLAUDE_CODE_ATTRIBUTION_HEADER = "0"
      # using claude-code with kimi llm
      # https://platform.moonshot.cn/docs/guide/agent-support
      # $env.ANTHROPIC_BASE_URL = "https://api.moonshot.cn/anthropic/"
      # $env.ANTHROPIC_AUTH_TOKEN = $env.MOONSHOT_API_KEY
      # $env.ANTHROPIC_DEFAULT_OPUS_MODEL = "kimi-k2.5"
      # $env.ANTHROPIC_DEFAULT_SONNET_MODEL = "kimi-k2.5"
      # $env.ANTHROPIC_DEFAULT_HAIKU_MODEL = "kimi-k2.5"

      # using claude-code with glm llm
      # https://docs.bigmodel.cn/cn/coding-plan/tool/claude
      # $env.ANTHROPIC_BASE_URL = "https://open.bigmodel.cn/api/anthropic"
      # $env.ANTHROPIC_AUTH_TOKEN = $env.ZAI_API_KEY
      # $env.ANTHROPIC_DEFAULT_OPUS_MODEL = "glm-5.1"
      # $env.ANTHROPIC_DEFAULT_SONNET_MODEL = "glm-5-turbo"
      # $env.ANTHROPIC_DEFAULT_HAIKU_MODEL = "glm-4.5-air"

      # using claude-code with minimax llm
      # https://platform.minimax.io/docs/token-plan/claude-code
      # $env.ANTHROPIC_BASE_URL = "https://api.minimax.io/anthropic"
      # $env.ANTHROPIC_AUTH_TOKEN = $env.MINIMAX_API_KEY
      # $env.ANTHROPIC_MODEL = "MiniMax-M2.7"
      # $env.ANTHROPIC_DEFAULT_OPUS_MODEL = "MiniMax-M2.7"
      # $env.ANTHROPIC_DEFAULT_SONNET_MODEL = "MiniMax-M2.7"
      # $env.ANTHROPIC_DEFAULT_HAIKU_MODEL = "MiniMax-M2.7"


      # Directories in this constant are searched by the
      # `use` and `source` commands.
      const NU_LIB_DIRS = $NU_LIB_DIRS ++ ['${nu_scripts}']

      # -*- completion -*-
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
      use custom-completions/zoxide/zoxide-completions.nu *

      # -*- alias -*-
      use aliases/git/git-aliases.nu *
      use aliases/eza/eza-aliases.nu *
      use aliases/bat/bat-aliases.nu *
      use ${./aliases/gcloud.nu} *

      # -*- modules -*-
      # argx & lg is required by the kubernetes module
      use modules/argx *
      use modules/lg *
      # k8s/helm aliases, completions, 
      use modules/kubernetes *
      # a wrapper around the jc cli tool, convert cli outputs to nushell tables
      # use modules/jc
    '';
  };
}
