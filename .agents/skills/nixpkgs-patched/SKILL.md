---
name: nixpkgs-patched
description:
  Use when temporarily carrying an unmerged nixpkgs pull request or commit in the personal
  ryan4yin/nixpkgs fork, updating the nixos-unstable-patched branch, or consuming that branch from
  this nix-config flake, including a WORKAROUNDS.md row whose removal condition is carrying the
  patch.
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
git fetch origin nixos-unstable
git fetch fork nixos-unstable-patched
gh pr view <pr> --repo NixOS/nixpkgs --json state,baseRefName,commits
```

The intended fork is `ryan4yin/nixpkgs` and the intended branch is `nixos-unstable-patched`. In
`~/src/nixpkgs`, `origin` is `NixOS/nixpkgs` and the fork is `fork` (or `ryan4yin`); never push the
patched branch to `origin`. Confirm the names; do not infer a remote from its position in the list.

## 2. Refresh the patched branch

Do this in the nixpkgs checkout (`~/src/nixpkgs`), preserving any existing work:

1. Save a rollback ref to the current patched tip.
2. Align the branch with the current `origin/nixos-unstable`.
3. Cherry-pick the exact PR commit(s), using `-x` so the upstream source remains recorded.
4. Resolve conflicts deliberately and inspect the complete diff against upstream.

If alignment rewrites the remote branch, this is an impactful GitHub operation: preview the new
history and push only with `--force-with-lease`, never `--force`. Stop if the remote changed in an
unexpected way. An upstream PR targets `master` unless it says otherwise, while the patched branch
tracks `nixos-unstable`; confirm the PR's base commit is contained in `nixos-unstable` before
cherry-picking, and stop if the patch depends on unreleased changes. If the PR depends on another
PR, review both changes and record their order.

## 3. Validate before publishing

For a local patched-branch update, validate only the package(s) the user intends to use. Use normal
Nix commands from the nixpkgs checkout, such as `nix build .#<package>` or a specifically requested
`passthru.tests.<name>`. These commands build their required dependencies; do not separately build
or test unrelated packages just because they changed on the branch.

`nixpkgs-review` is for reviewing an upstream nixpkgs PR. Do not use it to validate ordinary local
package use or a patched-branch lock update. For this workflow, inspect the diff and commit list:

```bash
git diff --check
git log --oneline --decorate origin/nixos-unstable..HEAD
```

Run package builds or tests only when the user requests them or when the selected package is needed
to complete the requested local verification. Record which package and checks were actually run;
never imply that unrelated packages or platforms were covered.

## 4. Publish and consume it

After authorization and validation:

```bash
git push --force-with-lease fork nixos-unstable-patched
git ls-remote fork refs/heads/nixos-unstable-patched
```

Then in this repository, update only the patched input and inspect the lock diff:

```bash
nix flake update nixpkgs-patched
git diff -- flake.lock
just test
just eval-host <affected-host>
just build-host <affected-host>
```

The nix-config eval and host-build commands validate this configuration. They are not a reason to
build every package in the patched nixpkgs branch. Run a host build only for a host that consumes
the changed package and only when the user asks for that validation.

Keep the nixpkgs fork change, lock update, and unrelated configuration changes separate. Do not run
`just niri`, `just local`, or a remote deployment from this skill; activation is a separate
authorized step in `nix-config-update`.

## 5. Roll back

If validation fails, restore the fork branch from the saved ref, update the lock back to the
previous revision, and re-run the affected checks. If the branch was already pushed, restoring it is
another impactful remote change: confirm the current remote tip and use `--force-with-lease`.
