{ pkgs, ... }:
{
  # Default editor: Helix (`hx`), for interactive and privileged (`sudoedit`) edits alike. This is
  # the single source for the editor env; Home Manager does not duplicate it. `SUDO_EDITOR` is
  # explicit rather than relying on the `$VISUAL`/`$EDITOR` fallback. Neovim stays installed as a
  # backup.
  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
    SUDO_EDITOR = "hx";
  };

  environment.systemPackages = with pkgs; [
    # core tools
    nushell # nushell
    fastfetch
    helix # default $EDITOR (`hx`)
    neovim # backup editor
    gnumake # Makefile
    just # a command runner like gnumake, but simpler
    git # used by nix flakes
    git-lfs # used by huggingface models

    # archives
    zip
    xz
    zstd
    unzipNLS
    p7zip

    # Text Processing
    # Docs: https://github.com/learnbyexample/Command-line-text-processing
    gnugrep # GNU grep, provides `grep`/`egrep`/`fgrep`
    gawk # GNU awk, a pattern scanning and processing language
    gnutar
    gnused # GNU sed, very powerful(mainly for replacing text in files)
    sad # CLI search and replace, just like sed, but with diff preview.

    jq # A lightweight and flexible command-line JSON processor
    yq-go # yaml processor https://github.com/mikefarah/yq

    # Interactively filter its input using fuzzy searching, not limit to filenames.
    fzf
    # search for files by name, faster than find
    fd
    findutils
    # search for files by its content, replacement of grep
    ripgrep

    duf # Disk Usage/Free Utility - a better 'df' alternative
    gdu # disk usage analyzer, non-interactive (`-n`) & JSON (`-o`)

    # networking tools
    mtr # A network diagnostic tool(traceroute)
    gping # ping, but with a graph(TUI)
    dnsutils # `dig` + `nslookup`
    doggo # DNS client for humans
    curl
    xh # friendly, fast curl-like HTTP client (Rust)
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    iperf3 # network performance test
    tcpdump # network sniffer

    # file transfer
    rsync
    croc # File transfer between computers securely and easily

    # security
    libargon2
    openssl

    # misc
    file
    which
    tree
    tealdeer # a very fast version of tldr
    trash-cli # freedesktop trash can CLI: trash-list / trash-restore / trash-put / trash-empty
  ];
}
