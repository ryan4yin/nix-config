---
name: git-delivery
description:
  Use when preparing a Git commit, performing authorized GitHub operations such as working with
  issues or pull requests, or finishing a task after its pull request has merged.
---

# Git Delivery

Follow the repository's conventions and the always-loaded authorization, privacy, and user-work
boundaries. This skill supplies delivery details; it grants no permission to commit, push, or merge.

## Commits and pull requests

| Deliverable    | Guidance                                                                                                                                                                     |
| -------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Commit subject | Derive it from the staged diff. Follow repository conventions; default to Conventional Commits. Aim for 50 characters, with 72 as the ceiling.                               |
| Commit body    | Usually omit it. Add a sentence for a constraint, side effect, or easily missed reason the diff cannot explain; use a few lines only for a genuinely complex change.         |
| PR description | Lead with the problem and resulting behavior. Explain scope and non-obvious rationale, then report verification actually run and its limits. Follow the repository template. |
| History        | Keep each commit a working logical change. Squash privacy or style fix-ups into the commit they fix only within the authorized history-edit boundary.                        |

For a small timeout fix, a complete commit message is:

```text
fix: increase request timeout to 1000ms
```

Use `gh` for authorized GitHub operations and SSH for GitHub Git remotes. Preserve the Nix-managed
`~/.ssh/config`; if the sandbox rejects it, request the permitted retry outside the sandbox rather
than bypassing the config or switching to HTTPS. Put multiline PR text in a temporary file and pass
`--body-file`. Review the exact outgoing content for privacy before the first push.

## After merge

When a PR opened by the agent is confirmed merged, finish its task:

1. Confirm the repository, default branch, and which local branch and worktrees this task created.
2. Check tracked and untracked changes. Remove only clean task-owned worktrees, from outside them,
   after confirming their resolved paths; preserve other worktrees and unexpected files.
3. Delete only the task-owned local branch with `git branch -d`. If Git refuses, including after a
   squash merge, skip and report instead of forcing.
4. Fetch the relevant remote and fast-forward the default branch only when its checkout is free of
   user work. If it is dirty, occupied, or diverged, skip and report instead of resetting it.
5. Verify the cleanup and fast-forward results. Keep the PR branch and worktree while review is
   ongoing; remote branch deletion requires its own authorization.

## Common mistakes

- Choosing a message from the conversation instead of the staged diff.
- Repeating a self-explanatory diff in a commit body or narrating the investigation in a PR.
- Treating a skill, commit request, or successful check as authorization for additional publication.
- Inferring worktree ownership from its directory name instead of the task's creation record.
