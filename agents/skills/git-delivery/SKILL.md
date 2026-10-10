---
name: git-delivery
description:
  Writes commit messages, pull/merge request and issue text, and review replies that follow the
  target repository's conventions, and cleans up after merge. Use when committing, opening or
  updating a PR/MR or issue, answering code review, or finishing after a reviewed change merges.
---

# Git Delivery

A diff that needs a long explanation is a diff to fix first: rename the thing, split the commit, or
put the reason in a comment at its primary location. Delivery text carries only what no artifact can
show, for a reader without the task's context: the reviewer now, and the maintainer reading
`git log` or `git blame` years later. The caps below are the standard: a draft over a cap is cut
until it fits, not justified. This skill grants no authorization.

Read [examples.md](examples.md) for short messages and descriptions that follow these rules.

## Before writing

Run `git log --no-merges -n 20 -- <touched paths>` and read any contribution guide and PR template,
every time, even for a one-line change. Name in one line the convention you followed and where you
found it.

1. The repository's conventions override the defaults below. Supply required metadata (sign-off,
   links, AI disclosure) only when true; never invent identities, and do not carry one repository's
   requirements into another.
2. Identify the comparison base and destination separately. Report an identity or hosting-account
   mismatch instead of editing Git config.
3. Describe what is actually delivered: the staged diff for a commit, the full diff against the base
   for a PR — not the task title or an earlier attempt.
4. Collect what the diff cannot show: the problem and its impact, costs and side effects (with
   numbers when measured), and rejected alternatives a reader would otherwise propose. The caps
   decide what survives. Ask instead of inventing a reason.

## Commit messages

- Subject: the repository's prefix convention, defaulting to Conventional Commits; imperative,
  aiming at 50 characters with 72 as the ceiling.
- Body: zero lines unless the change has an effect the diff does not show — data deleted or
  rewritten outside the changed lines, a stored format or an option other code reads changing
  meaning, or a running system touched beyond what the changed lines say. A version bump, a config
  value, a moved and re-grouped file, or a formatter, lint, or build setting states its own effect:
  no body. When a trigger applies: at most 2 sentences and 40 words, and every sentence names an
  effect, not a motive. Otherwise the reason goes in the subject when it fits inside the ceiling.
  Never in a body: file lists, change counts, the measurement that motivated the change,
  alternatives, or how the problem was found.
- Summarize an issue instead of only linking it; cite another commit by abbreviated hash and
  subject. Trailers go last in the repository's format (`Fixes:`, `Refs:`, `Signed-off-by:`,
  `BREAKING CHANGE:`), and credit other people only as the repository's policy allows. Notes meant
  only for current reviewers, such as changes since the last round, stay out.
- Pass the message with `git commit -F <file>` or one `-m` per paragraph. If a hook rejects the
  commit, nothing was committed: fix the cause and commit again, since `--amend` would rewrite the
  previous commit.

## Pull/merge requests

The description often becomes the squash-merge message. Check for an existing open PR for the same
branch or issue.

- Title: a commit subject for the whole change.
- Body: at most 80 words normally, or 160 only for migration or rollback steps, a risk the reviewer
  must weigh, or a measured result the reviewer cannot see. Use short paragraphs or up to 5 bullets
  to separate distinct points; brevity should make the change easy to scan. Lead with the changed
  behavior and its effect. Follow the repository template when one exists; check only boxes that are
  true. Add only what the change needs: a breaking change names the affected interface, before and
  after, and the migration; an operational one names the operator effect and measured impact; a
  cross-cutting one says why the breadth is necessary and where review should start.
- Self-check before submitting: count. Subject ≤72 characters; commit body 0 lines, or ≤2 sentences
  and ≤40 words; description ≤80 words, or ≤160 with one of the named triggers. Over a cap, cut in
  this order until under: anything the diff already shows, then supporting numbers, then
  alternatives, then adjectives. Report the counts with the draft.
- Do not add default Summary/Changes/Test Plan headings, pasted commands, CI logs, commit lists, or
  exhaustive file lists, and cut any sentence a reviewer cannot act on. Replace internal process
  terms (plan steps, task numbers, agent names) with the behavior they refer to.
- Verification: report the checks that establish behavior or coverage, with revision and platform;
  skip routine lint. A build does not show runtime behavior. Once the code changes, an earlier
  result is historical: rerun it or label it and say what remains unverified.
- `Fixes #123` only for a verified issue in the target repository that this change resolves; `Refs`
  only links.
- Write as if the diff had been written in one pass: state what is excluded and why, not who asked
  or how the branch evolved. When later commits change scope, risk, or migration, rewrite title and
  description. After a follow-up push, answer in the existing threads, naming the new commit; do not
  post a separate summary of what changed since the last round unless the repository's guide or a
  reviewer asks.
- Pass multiline text from a file (`gh pr create --body-file`) and keep the configured Git transport
  and identity when submitting fails. Before publishing, review the exact outgoing text for internal
  identifiers, private paths, and anything not already public in that repository.

## Review replies

- Treat each comment as a claim to check against the code and the repository's rules; reviewers and
  review bots can be wrong. Ask when a comment is unclear.
- If a reviewer misunderstood the code, make the code clearer or add a comment first; a reply alone
  does not help later readers.
- Answer in the thread, naming the commit (`Fixed in 1a2b3c4: ...`). Keep replies to accepted
  comments short; give declined ones the full reasoning and the tradeoff weighed. Skip filler.
- Resolve a thread only when addressed and the repository expects authors to resolve. Never claim a
  fix or check that did not happen. An approval covers only what that reviewer reviewed, and notify
  only relevant reviewers.

## After merge

For a confirmed-merged PR the agent opened: identify its branches and worktrees from the task
record, not by name pattern; remove a worktree only when clean and from outside it; delete the local
branch with `git branch -d` and report when it refuses instead of forcing; fast-forward the default
branch only when its checkout is clean and not diverged, then verify. Keep branches while review is
open; deleting a remote branch needs separate authorization.
