{ pkgs, ... }:
{
  # for security reasons, do not load neovim's user config
  # since EDITOR may be used to edit some critical files
  environment.variables.EDITOR = "nvim --clean";

  environment.systemPackages = with pkgs; [
    # core tools
    nushell # nushell
    fastfetch
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    gnumake # Makefile
    just # a command runner like gnumake, but simpler
    git # used by nix flakes
    git-lfs # used by huggingface models

    # system monitoring
    procs # a moreden ps
    btop

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
    jc # converts the output of popular cli tools & file-types to JSON, YAML

    # Interactively filter its input using fuzzy searching, not limit to filenames.
    fzf
    # search for files by name, faster than find
    fd
    findutils
    # search for files by its content, replacement of grep
    (ripgrep.override { withPCRE2 = true; })

    duf # Disk Usage/Free Utility - a better 'df' alternative
    dust # A more intuitive version of `du` in rust
    gdu # disk usage analyzer(replacement of `du`)
    ncdu # analyzer your disk usage Interactively, via TUI(replacement of `du`)

    # networking tools
    mtr # A network diagnostic tool(traceroute)
    gping # ping, but with a graph(TUI)
    dnsutils # `dig` + `nslookup`
    ldns # replacement of `dig`, it provide the command `drill`
    doggo # DNS client for humans
    wget
    curl
    curlie # curl with httpie
    httpie
    aria2 # A lightweight multi-protocol & multi-source command-line download utility
    socat # replacement of openbsd-netcat
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses
    iperf3 # network performance test
    hyperfine # command-line benchmarking tool
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
  ];
}
