---
name: git-delivery
description:
  Use when writing a Git commit message, creating or updating a pull/merge request or hosted issue,
  replying to code review, or cleaning up branches and worktrees after a reviewed change has merged.
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

1. Read the target repository's conventions: contribution guide, PR template, and
   `git log --no-merges` on the touched files for subject prefixes, trailers, and body style. They
   override the defaults below. Supply required metadata (sign-off, issue or release links, AI
   disclosure) only when it is true; never invent identities or reviews, or carry one repository's
   requirements into another.
2. Identify the comparison base and destination separately (fork, release branch, an existing PR's
   base), and check that the commit identity and hosting account fit this repository.
3. Inspect what is actually delivered: the final staged diff for a commit; every commit plus the
   full diff against the base for a PR. Describe that, not the task title or an earlier attempt.
4. Collect what the diff cannot show from the task and existing observations: the problem and its
   user-visible impact, why this approach, costs and side effects (with numbers when measured),
   constraints, and rejected alternatives a reader would otherwise propose. Keep observations
   separate from inferences; gather more evidence only within the task's scope.

## Commit messages

- Subject: what the commit does, in imperative mood; it should complete "If applied, this commit
  will ...". Use the repository's prefix (`area:`, `type(scope):`), defaulting to Conventional
  Commits. Aim for 50 characters, 72 at most, no trailing period.
- Body: omit it when the subject and diff say everything. Otherwise describe the problem as it
  exists without the change, why this change solves it, and side effects, costs, or compatibility
  consequences. Leave out line-by-line mechanics and how the problem was found. Wrap at 72 columns
  unless the repository differs.
- Self-contained: summarize the relevant point of an issue or discussion instead of only linking it.
  Cite another commit by abbreviated hash and subject.
- Trailers go last, in the repository's format (`Fixes:`, `Refs:`, `Signed-off-by:`,
  `BREAKING CHANGE:`). Name other people in credit trailers only as the repository's policy allows.
- One logical change per commit. A subject that needs "and" suggests a split. Notes meant only for
  current reviewers, such as changes since the last round, stay out of the message.

## Pull/merge requests

The description informs the reviewer now and often becomes the squash-merge message.

- Title: a commit subject for the whole change.
- Body: lead with the problem and resulting behavior, then what a reviewer needs to judge it:
  approach and why, scope and deliberate exclusions, risks and tradeoffs, where to focus review, and
  verification. Keep the template's required fields; check only boxes that are true.
- Verification: state what ran, against which revision and platform, and what it establishes. A
  build does not show runtime behavior; a unit test does not show the user workflow. Once the
  relevant code changes, an earlier result is historical: rerun it, or label it and say what remains
  unverified. Do not describe a change as live before it is deployed.
- Closing keywords (`Fixes #123`) only for a verified issue in the target repository that this
  change resolves.
- When review changes the implementation, rewrite title and description to match the final diff;
  summarize changes since the last review in a comment instead of appending history.
- Pass multiline text from a file or structured argument (e.g. `gh pr create --body-file`). Keep the
  configured Git transport and identity; do not switch them to work around a failure.
- Review the exact outgoing text before publishing: no internal identifiers, private paths, raw
  logs, or anything not already public in that repository.

## Review replies

- If a reviewer misunderstood the code, first make the code clearer or add a comment; a reply alone
  does not help later readers. A question that leads to no code change often deserves a note in the
  commit message.
- Answer the specific point: the decision, its evidence, and what remains open. When disagreeing,
  state the tradeoff you weighed and ask what the reviewer weighs differently. Do not concede
  without a reason, or claim a fix or check that did not happen.
- Reply in the relevant thread and notify only relevant reviewers. An approval covers only what that
  reviewer reviewed.

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
