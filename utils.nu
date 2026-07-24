def repeat-str [s: string, n: int] {
  (1..$n | each { $s } | str join)
}

# ================= NixOS related =========================

export def nixos-switch [
    name: string
    mode: string
    verbosity: string
] {
    if $mode not-in ["switch" "boot"] {
        error make { msg: $"unsupported deployment mode '($mode)'; expected switch or boot" }
    }
    if $verbosity not-in ["normal" "debug"] {
        error make { msg: $"unsupported verbosity '($verbosity)'; expected normal or debug" }
    }

    print $"nixos-switch '($name)' in '($mode)' mode with '($verbosity)' verbosity..."
    print (repeat-str "=" 50)
    if $verbosity == "debug" {
        # show details via nix-output-monitor
        nom build $".#nixosConfigurations.($name).config.system.build.toplevel" --accept-flake-config --show-trace --verbose
        nixos-rebuild $mode --sudo --flake $".#($name)" --accept-flake-config --show-trace --verbose
    } else {
        nixos-rebuild $mode --sudo --flake $".#($name)" --accept-flake-config
    }
}


# ====================== Misc =============================

export def make-editable [
    path: string
] {
    print (repeat-str "=" 50)
    let tmpdir = (mktemp -d)
    rsync -avz --copy-links $"($path)/" $tmpdir
    rsync -avz --copy-links --chmod=D2755,F744 $"($tmpdir)/" $path
}


# ================= macOS related =========================

export def darwin-build [
    name: string
    verbosity: string
] {
    print $"darwin-build '($name)' with '($verbosity)' verbosity..."
    print (repeat-str "=" 50)
    let target = $".#darwinConfigurations.($name).system"
    if "debug" == $verbosity {
        nom build $target --extra-experimental-features "nix-command flakes"  --show-trace --verbose
    } else {
        nix build $target --extra-experimental-features "nix-command flakes"
    }
}

export def darwin-switch [
    name: string
    verbosity: string
] {
    print $"darwin-switch '($name)' with '($verbosity)' verbosity..."
    print (repeat-str "=" 50)
    if "debug" == $verbosity {
        sudo -E ./result/sw/bin/darwin-rebuild switch --flake $".#($name)" --show-trace --verbose
    } else {
        sudo -E ./result/sw/bin/darwin-rebuild switch --flake $".#($name)"
    }
}

export def darwin-rollback [] {
    ./result/sw/bin/darwin-rebuild --rollback
}

# ==================== Virtual Machines related =====================

# Build and upload a VM image
export def upload-vm [
    name: string
    verbosity: string
] {
    print $"upload-vm '($name)' with '($verbosity)' verbosity..."
    print (repeat-str "=" 50)
    let target = $".#($name)"
    if "debug" == $verbosity {
        nom build $target --show-trace --verbose
    } else {
        nix build $target
    }

    let remote = $"root@192.168.5.178:/data/caddy/fileserver/vms/kubevirt-($name).qcow2"
    rsync -avz --progress --copy-links --checksum result/nixos-image-*.qcow2 $remote
}
