---
name: git-delivery
description:
  Use when preparing a Git commit, performing authorized GitHub operations such as working with
  issues or pull requests, or finishing a task after its pull request has merged.
---

# Git Delivery

Follow repository conventions and the always-loaded authorization, privacy, and user-work
boundaries. This skill grants no permission to commit, push, or merge.

## Before delivery

Read repository instructions, applicable contribution guides, the PR template, and recent commits in
the touched area. Identify the comparison base, push destination, and PR repository separately;
existing PRs supply their current base/head. Check Git attribution and the GitHub account when
moving between personal and work repositories.

## Commits and pull requests

| Deliverable    | Guidance                                                                                                                                                                                                                                              |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Commit subject | Derive it from the final staged diff. Follow repository conventions; otherwise default to Conventional Commits. Aim for 50 characters, with 72 as the ceiling.                                                                                        |
| Commit body    | Usually omit explanatory prose for self-evident changes. Retain required release/changelog links, issue references, and trailers. Explain a constraint, side effect, or reason the diff cannot show; one sentence usually suffices.                   |
| PR description | Review every commit and the full branch diff against its base. Lead with the problem and resulting behavior, then scope, non-obvious rationale, and actual verification with limits. Preserve the template and refresh title/body when scope changes. |
| History        | Keep commits independently reviewable and working. Squash style/privacy fix-ups only within the authorized history-edit boundary.                                                                                                                     |

For nixpkgs package changes, read `CONTRIBUTING.md` and the relevant area's `README.md`; use the
attribute prefix, for example `hello: 2.12.1 -> 2.12.2`, rather than a Conventional Commit prefix.
Follow its current automation policy, including applicable human review, `Assisted-by` trailers, and
separate disclosure for generated PR text or reviews. Other repositories set their own policy.

Use `gh` for authorized GitHub operations and SSH for GitHub Git remotes. Preserve the Nix-managed
`~/.ssh/config`; retry outside the sandbox when permitted if it is rejected, without bypassing the
config. Pass multiline PR text using `--body-file`. Verify issue references and scan exact outgoing
content for privacy before publication.

## Review replies

Answer the technical point directly: the decision, supporting code or test evidence, and any
remaining limitation. Correct disproven claims; explain necessary exceptions to project mechanisms.
Reply in the relevant thread and contact only relevant reviewers within the authorized scope.

## After merge

For a confirmed merged PR opened by the agent:

1. Confirm the repository, default branch, and task-created branches/worktrees from creation
   records.
2. Check tracked/untracked changes and resolved paths. Remove only clean task-owned worktrees from
   outside them; preserve unexpected files and other worktrees.
3. Delete only the task-owned local branch with `git branch -d`; skip/report refusals, including
   after squash merges, without forcing.
4. Fetch and fast-forward the default branch only if its checkout is free of user work; skip/report
   dirty, occupied, or diverged state. Verify cleanup and update results.

Keep the branch/worktree during review. Remote branch deletion needs separate authorization.

## Common mistakes

- Assuming `main` or `origin` instead of checking the intended destination.
- Narrating investigation/review history or repeating obvious code in delivery text.
- Treating skills, successful checks, or directory names as authorization or ownership evidence.
