---
name: git-delivery
description:
  Writes commit messages, pull/merge request and issue text, and review replies that follow the
  target repository's conventions, and cleans up after merge. Use when committing, opening or
  updating a PR/MR or issue, answering code review, or finishing after a reviewed change merges.
---

# Git Delivery

A diff shows what changed. Delivery text records why, for a reader without the task's context: the
reviewer now, and the maintainer reading `git log` or `git blame` years later. Write plainly and
specifically; reviewers distrust generic, inflated text. This skill grants no authorization:
commits, pushes, hosting writes, and merges still need the authorization the governing rules
require.

Read [examples.md](examples.md) for annotated messages from the Git, Linux, Google, and Conventional
Commits guidance when shaping a body, a PR description, or a review reply.

## Before writing

**First, every time, even for a one-line change:** run
`git log --no-merges -n 20 -- <touched paths>` and read the contribution guide and PR template if
present. When you present a draft, name in one line the convention you followed and where you found
it.

1. The repository's subject prefixes, trailers, and body style override the defaults below, which
   apply only when the repository shows no convention. Supply required metadata (sign-off, issue or
   release links, AI disclosure) only when it is true; never invent identities or reviews, or carry
   one repository's requirements into another.
2. Identify the comparison base and destination separately (fork, release branch, an existing PR's
   base). Check that the commit identity and hosting account fit this repository; report a mismatch
   instead of editing Git config.
3. Inspect what is actually delivered: the final staged diff for a commit; every commit plus the
   full diff against the base for a PR. Describe that, not the task title or an earlier attempt.
4. Collect what the diff cannot show from the task and existing observations: the problem and its
   user-visible impact, why this approach, costs and side effects (with numbers when measured),
   constraints, and rejected alternatives a reader would otherwise propose. Keep observations
   separate from inferences. If the purpose is unclear, ask instead of inventing a reason.

## Commit messages

- Subject: the repository's prefix convention (`area:`, `type(scope):`), defaulting to Conventional
  Commits; imperative, aiming at 50 characters with 72 as the ceiling.
- Body: omit it when the subject and diff say everything. Otherwise describe the problem as it
  exists without the change, why this change solves it, and side effects, costs, or compatibility
  consequences. Leave out line-by-line mechanics and how the problem was found.
- Summarize the relevant point of an issue or discussion instead of only linking it. Cite another
  commit by abbreviated hash and subject.
- Trailers go last, in the repository's format (`Fixes:`, `Refs:`, `Signed-off-by:`,
  `BREAKING CHANGE:`). Name other people in credit trailers only as the repository's policy allows.
- Notes meant only for current reviewers, such as changes since the last round, stay out of the
  message.
- Pass the message with `git commit -F <file>` or one `-m` per paragraph, never an editor or literal
  `\n`. Never bypass hooks (`--no-verify`, `-c core.hooksPath=...`) without the user's
  authorization. If a hook rejects the commit, nothing was committed: fix the cause and commit
  again, since `--amend` would rewrite the previous commit.

## Pull/merge requests

The description informs the reviewer now and often becomes the squash-merge message. Before opening
one, check for an existing open PR for the same branch or issue.

- Title: a commit subject for the whole change.
- Body: lead with the changed behavior and its effect, then only what helps a reviewer judge it.
  Follow the repository template when one exists; check only boxes that are true. Otherwise pick the
  smallest shape that fits:

  | Change                     | Include                                                         |
  | -------------------------- | --------------------------------------------------------------- |
  | Small or obvious           | One paragraph, no headings.                                     |
  | Bug fix, feature, refactor | Behavior and effect; root cause or non-obvious approach if any. |
  | Contract or breaking       | Affected interface, before/after, compatibility, migration.     |
  | Operational or visual      | User or operator effect, measured impact, rollout, screenshots. |
  | Broad or cross-cutting     | Why the breadth is necessary and where review should start.     |

- Do not add default Summary/Changes/Test Plan headings, pasted commands, CI logs, commit lists, or
  exhaustive file lists. Replace internal process terms (plan steps, task numbers, agent names) with
  the behavior they refer to.
- Verification: report checks that establish behavior or coverage, against which revision and
  platform; skip routine lint and formatting. A build does not show runtime behavior; a unit test
  does not show the user workflow. Once the relevant code changes, an earlier result is historical:
  rerun it, or label it and say what remains unverified. Do not describe a change as live before it
  is deployed.
- Closing keywords (`Fixes #123`) only for a verified issue in the target repository that this
  change resolves; `Refs` only links.
- Write the description as if the final diff had been written in one pass: state what is excluded
  and why, without who asked for it or how the branch evolved. When later commits change scope,
  approach, risk, or migration, rewrite title and description to match, and summarize changes since
  the last review in a comment. Typo-only or formatting-only follow-ups need no rewrite.
- Pass multiline text from a file or structured argument (e.g. `gh pr create --body-file`). Keep the
  configured Git transport and identity; do not switch them to work around a failure.
- Review the exact outgoing text before publishing: no internal identifiers, private paths, raw
  logs, or anything not already public in that repository.

## Review replies

- Treat each comment as a claim to check against the code, the repository's rules, and the linked
  issue; reviewers and review bots can be wrong. Ask when a comment is unclear.
- If a reviewer misunderstood the code, first make the code clearer or add a comment; a reply alone
  does not help later readers.
- Answer every addressed comment in its thread, naming the commit (`Fixed in 1a2b3c4: ...`). Keep
  replies to accepted comments short; give declined ones the full reasoning: what you checked, what
  it showed, and the tradeoff you weighed. Skip filler such as "Great catch!".
- Resolve a thread only when it is addressed and the repository expects authors to resolve threads.
  Do not claim a fix or check that did not happen. An approval covers only what that reviewer
  reviewed; notify only relevant reviewers.

## After merge

For a confirmed-merged PR the agent opened:

1. Identify the branch and worktrees the task created from its own record, not by name pattern.
2. Remove a task-owned worktree only when it is clean, running the command from outside it.
3. Delete the local branch with `git branch -d`; when it refuses (e.g. after a squash merge), report
   instead of forcing.
4. Fast-forward the default branch only when its checkout is clean and not diverged; verify the
   result.

Keep branches and worktrees while review is open. Deleting the remote branch needs separate
authorization.
