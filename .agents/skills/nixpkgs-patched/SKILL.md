---
name: Nixpkgs Patched
description:
  Use when temporarily carrying an unmerged nixpkgs pull request or commit in the personal
  ryan4yin/nixpkgs fork, updating the nixos-unstable-patched branch, or consuming that branch from
  this nix-config flake.
---

# Carrying a nixpkgs patch

This is a temporary supply-chain change across two repositories:

```text
upstream nixpkgs PR → personal fork branch → nix-config lock entry → host/package validation
```

Keep the upstream commit identifiable, keep a rollback ref, and never activate a host merely because
the fork branch pushed successfully.

## 1. Confirm the exact target

Before changing either repository, confirm the remotes, branch, PR commits, and local work:

```bash
git remote -v
git status --short
git branch --show-current
git fetch upstream nixos-unstable
git fetch origin nixos-unstable-patched
gh pr view <pr> --repo NixOS/nixpkgs --json state,baseRefName,commits
```

The intended fork is `ryan4yin/nixpkgs` and the intended branch is `nixos-unstable-patched`. Confirm
those names; do not infer a remote from its position in the remote list.

## 2. Refresh the patched branch

Do this in the nixpkgs checkout, preserving any existing work:

1. Save a rollback ref to the current patched tip.
2. Align the branch with the current `upstream/nixos-unstable`.
3. Cherry-pick the exact PR commit(s), using `-x` so the upstream source remains recorded.
4. Resolve conflicts deliberately and inspect the complete diff against upstream.

If alignment rewrites the remote branch, this is an impactful GitHub operation: preview the new
history and push only with `--force-with-lease`, never `--force`. Stop if the remote changed in an
unexpected way. If the PR depends on another PR, review both changes and record their order.

## 3. Validate before publishing

In the nixpkgs checkout, run the smallest relevant checks first:

```bash
git diff --check
git log --oneline --decorate upstream/nixos-unstable..HEAD
nixpkgs-review rev HEAD --no-shell --print-result
```

Build the affected package and its relevant tests. A cherry-pick that applies cleanly can still be
invalid against the current unstable base. Record the source PR, commit IDs, base revision, package,
and test result before pushing.

## 4. Publish and consume it

After authorization and validation:

```bash
git push --force-with-lease origin nixos-unstable-patched
git ls-remote origin refs/heads/nixos-unstable-patched
```

Then in this repository, update only the patched input and inspect the lock diff:

```bash
nix flake update nixpkgs-patched
git diff -- flake.lock
just test
just eval-host <affected-host>
just build-host <affected-host>
```

Keep the nixpkgs fork change, lock update, and unrelated configuration changes separate. Do not run
`just niri`, `just local`, or a remote deployment from this skill; activation is a separate
authorized step in `nix-config-update`.

## 5. Roll back

If validation fails, restore the fork branch from the saved ref, update the lock back to the
previous revision, and re-run the affected checks. If the branch was already pushed, restoring it is
another impactful remote change: confirm the current remote tip and use `--force-with-lease`.
