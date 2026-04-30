# Permissions Configuration

This document records the current permission requirements for AI agents operating in this
repository.

## Scope

| Environment              | Policy                                      |
| ------------------------ | ------------------------------------------- |
| **Personal workstation** | Restrictive - protect user's daily workflow |
| **Homelab VMs**          | Permissive - agents have full autonomy      |

The permissions below apply to **personal workstation** only. For homelab VMs, almost everything is
allowed except destructive operations on production systems.

## Default Policy

| Tool             | Permission |
| ---------------- | ---------- |
| `*` (all others) | ask        |

## File Read Permissions

| Pattern         | Permission |
| --------------- | ---------- |
| `*` (all files) | allow      |
| `*.env`         | deny       |
| `*.env.*`       | deny       |
| `*.env.example` | allow      |
| `*.pem`         | deny       |
| `*.key`         | deny       |
| `*kubeconfig*`  | deny       |
| `.ssh/**`       | deny       |
| `.aws/**`       | deny       |
| `.kube/**`      | deny       |
| `.gnupg/**`     | deny       |

## Always Allowed Tools

These tools run without prompting:

- `glob`
- `grep`
- `lsp`
- `question`
- `skill`
- `webfetch`

## Bash Command Permissions

### Always Allowed (Read-only operations)

**Git:**

- `git status`, `git diff`, `git log`, `git show`, `git branch`, `git remote`

**Kubernetes:**

- `kubectl get`, `kubectl describe`, `kubectl logs`, `kubectl top`
- `kubectl api-resources`, `kubectl api-versions`
- `kubectl config view`, `kubectl config get-contexts`
- `kubectl kustomize`, `kustomize build`, `kustomize version`
- `kubectl explain`

**Terraform:**

- `terraform plan`, `terraform show`, `terraform state list`, `terraform state show`
- `terraform output`, `terraform version`, `terraform providers`, `terraform fmt`

**GitHub CLI:**

- `gh repo view/list`, `gh issue view/list`, `gh pr view/list/diff/checks`
- `gh api`, `gh search`, `gh gist list/view`
- `gh release view/list`, `gh workflow list/view`, `gh run list/view`
- `gh status`, `gh auth status`

**Helm:**

- `helm list`, `helm get`, `helm show`, `helm search`
- `helm repo list`, `helm status`, `helm version`, `helm template`

**Google Cloud:**

- `gcloud * list`, `gcloud * describe`, `gcloud * get-iam-policy`
- `gcloud config list`, `gcloud auth list`, `gcloud version`

**Nix:**

- `nix eval`, `nix build`, `nix flake show`, `nix flake metadata`
- `nix flake check`, `nix flake lock`
- `nix profile list`, `nix profile history`
- `nix store verify`, `nix store ls`, `nix store path-info`
- `nix search`, `nix doctor`, `nix --version`
- `nixos-rebuild build`, `darwin-rebuild build`
- `nom build`

**Just:**

- `just --list`, `just --show`, `just --dry-run`

**Linters & Formatters:**

- `statix check`, `deadnix`, `nixfmt --check`
- `shellcheck`, `hadolint`, `actionlint`
- `ruff check`, `clippy`, `prettier --check`
- `tokei`

**System diagnostics:**

- `systemctl status`, `systemctl list-units`, `systemctl show`
- `journalctl -u`, `journalctl --since`
- `lspci`, `lsusb`, `lsblk`, `df`, `free`, `uptime`, `uname -a`
- `sensors`, `lsof`

**Git (extended):**

- `git tag`, `git blame`, `git reflog`, `git stash list`
- `git lfs status`, `git lfs ls-files`

**Development tools:**

- `go version`, `go env`, `go list`, `go doc`, `go vet`
- `cargo --version`, `cargo tree`, `cargo metadata`
- `python3 --version`, `python3 -m py_compile`
- `node --version`, `pnpm list`, `uv pip list`

**General utilities:**

- `rg`, `fd`, `cp`, `mv`, `chmod`
- `ls`, `cat`, `head`, `tail`, `wc`, `find`, `which`
- `echo`, `pwd`, `date`, `env`, `printenv`
- `file`, `stat`, `du`, `tree`, `bat`, `eza`
- `jq`, `yq`, `tldr`
- `mkdir`, `rmdir`, `grep`

### Requires Confirmation

| Command    | Permission |
| ---------- | ---------- |
| `rm *`     | ask        |
| `rm -rf *` | ask        |

### Always Denied

| Command  | Permission |
| -------- | ---------- |
| `sudo *` | deny       |

## Homelab VM Permissions

For agents running in dedicated homelab VMs, permissions are significantly relaxed:

| Category             | Permission            |
| -------------------- | --------------------- |
| `bash`               | allow (most commands) |
| `edit`               | allow                 |
| `write`              | allow                 |
| `task`               | allow                 |
| `external_directory` | allow                 |
| `rm`                 | allow                 |

**Still restricted in homelab VMs:**

- Production cluster destructive operations (`kubectl delete`, `helm uninstall`)
- Infrastructure teardown (`terraform destroy`)
- Secret exposure in logs

## Other Tool Permissions

| Tool                 | Permission |
| -------------------- | ---------- |
| `edit`               | allow      |
| `write`              | allow      |
| `task`               | ask        |
| `external_directory` | ask        |
| `doom_loop`          | deny       |

## Summary

- **File operations**: `read`, `glob`, `grep`, `edit`, `write` all allowed in workspace
- **Nix operations**: Build/eval/flake commands auto-allowed (writes to store only)
- **Linting & formatting**: All check commands auto-allowed
- **System diagnostics**: Read-only system info auto-allowed
- **Sensitive files**: Credentials, keys, and cloud configs are blocked
- **Destructive operations**: `rm` requires explicit user confirmation
- **Privilege escalation**: `sudo` is completely blocked
- **Scope control**: `task` and `external_directory` require approval
