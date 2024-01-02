# ================= NixOS related =========================

export def nixos-switch [
    name: string
    mode: string
] {
    if "debug" == $mode {
        nixos-rebuild switch --use-remote-sudo --flake $".#($name)" --show-trace --verbose
    } else {
        nixos-rebuild switch --use-remote-sudo --flake $".#($name)"
    }
}


# ====================== Misc =============================

export def make-editable [
    path: string
] {
    let tmpdir = (mktemp -d)
    rsync -avz --copy-links $"($path)/" $tmpdir
    rsync -avz --copy-links --chmod=D2755,F744 $"($tmpdir)/" $path
}


# ================= macOS related =========================

const darwin_dir = './result/sw/bin'

export def darwin-build [
    name: string
    mode: string
] {
    let target = $".#darwinConfigurations.($name).system"
    with-env { PATH : ($env.PATH | prepend darwin_dir) } {
        if "debug" == $mode {
            nom build $target --show-trace --verbose
        } else {
            nix build $target
        }
    }
}

export def darwin-switch [
    name: string
    mode: string
] {
    with-env { PATH : ($env.PATH | prepend darwin_dir) } {
        if "debug" == $mode {
            darwin-rebuild switch --flake $".#($name)" --show-trace --verbose
        } else {
            darwin-rebuild switch --flake $".#($name)"
        }
    }
}

export def darwin-rollback [] {
    with-env { PATH : ($env.PATH | prepend darwin_dir) } {
        darwin-rebuild --rollback
    }
}
