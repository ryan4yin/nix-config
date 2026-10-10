---
name: git-delivery
description:
  Use when preparing a Git commit, working with hosted repository issues or pull/merge requests, or
  finishing a task after its reviewed changes have merged.
---

# Git Delivery

Write delivery text from the final change and verified, relevant context. Use the diff to check what
is included; use the task goal, observed behavior, constraints, and evidence to explain why it
matters. Follow repository conventions and the always-loaded authorization, privacy, and user-work
boundaries. This skill grants no permission to commit, push, or merge. PR also refers to the hosting
service's equivalent merge request here.

Read [examples.md](examples.md) when a small diff depends on runtime or operational context, a PR
contains several commits, evidence predates the final change, or repository conventions differ from
the default. It uses portable examples with explicitly stated repository requirements.

## Establish the delivery context

1. Read repository instructions, applicable contribution guides, the PR template, and recent commits
   in the touched area. Identify the comparison base, push destination, and PR repository
   separately. Existing PRs supply their current base/head. Check Git attribution and the hosting
   account when moving between personal and work repositories.
2. Recover the user's goal and the problem being solved from the task, existing code, and safe
   observations already collected. Record the meaningful trigger and previous behavior, final
   behavior, and affected users or systems. Collect further evidence only within the authorized
   scope, without inspecting secrets or dumping environments.
3. Identify the reasons a reviewer cannot infer from the diff: runtime lookup behavior, platform or
   deployment constraints, dependency/closure costs, compatibility requirements, and necessary
   exceptions to project mechanisms. Keep an alternative only when it explains the final choice.
4. Inspect the final staged changes for each commit and all commits plus the full branch diff for
   the PR. Reconcile this scope with the context: retain verified reasons for surviving changes;
   remove features, claims, and conclusions that the final implementation no longer supports.
5. Associate each verification result with the revision or configuration, platform, conditions, and
   workflow it actually tested. Distinguish observed facts, supported inferences, and unresolved
   hypotheses. Update this context whenever the implementation or relevant environment changes.

Keep this context in the task's working notes or conversation. Add a repository document only when
requested or when it belongs in existing project documentation; leave scratch and raw logs out of
commits.

## Put each fact where its reader needs it

| Location       | Information it should carry                                                                                                                         |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| Commit subject | The logical change in this commit, using the repository's vocabulary.                                                                               |
| Commit body    | Durable reasons, constraints, consequences, and required metadata that explain this commit to a future maintainer without the conversation.         |
| PR description | The problem and resulting behavior of the complete change, its scope, material rationale/tradeoffs, actual verification, and remaining limitations. |
| Code comment   | A contract or local constraint a maintainer must know while reading the code. Follow the global documentation rule.                                 |
| Review reply   | The answer to that technical point, evidence for the decision, and what remains unresolved.                                                         |

Give a fact a primary home for each audience and link when another location needs it. A maintainer
reading a commit and a reviewer reading a PR may both need the reason for a dependency; include it
briefly in each when necessary. Explanations should describe current behavior and obligations.
Investigation chronology belongs in discussion only when it helps resolve an open question.

## Write the commit

- Derive the subject from the final staged scope and its verified purpose, not from a task title or
  an earlier implementation. Follow repository conventions; otherwise default to Conventional
  Commits. Aim for 50 characters, with 72 as the ceiling.
- Usually omit explanatory prose for self-evident changes. Preserve required release/changelog
  links, issue references, and trailers. Add a body when the why, constraint, side effect, or
  compatibility consequence would otherwise be lost. One sentence often suffices; complex changes
  can need more.
- Keep commits independently reviewable and working. If the staged diff mixes unrelated changes,
  select only the authorized logical change and preserve user edits. Squash style/privacy fix-ups
  only within the authorized history-edit boundary.

Repository requirements can include component/package prefixes, issue identifiers, release links,
sign-offs, attribution, automation disclosure, or human review before submission. Read the current
policy and preserve applicable requirements even when explanatory prose is unnecessary. Do not
invent metadata, identity, or a review that has not happened, or carry one repository's policy into
another.

## Write or update the PR

Lead with the concrete problem and resulting behavior. Explain only the scope and rationale that a
reviewer needs to assess the full change; include material operational effects even when the diff is
small. Follow the repository template and verify issue references before using closing keywords.

For an existing PR, inspect its current base/head, title, and body. Review every branch commit and
the complete diff against that base; an update may include changes beyond the latest commit. When
scope changes, rewrite title/body around the final implementation and reconcile removed features,
tradeoffs, verification claims, and template checkboxes.

Report relevant checks actually run, what each establishes, and meaningful limits. A successful
build establishes buildability on that platform; it does not establish hardware execution, rollout
health, or the complete user workflow. Results from an earlier revision remain historical evidence
unless still valid for the current change. Re-run affected checks when justified; otherwise label
the older result and state what the final revision has not verified. Do not imply an edit is active
before the required deployment or restart.

Use the hosting service's supported tooling; for GitHub, use `gh` for authorized operations. Keep
the configured Git transport and authentication settings. If the sandbox rejects that configuration,
use a permitted retry without bypassing it or silently switching identities/transports. Pass
multiline text through a supported file or structured argument (`--body-file` with `gh`). Review the
exact commits and outgoing text for privacy before publication, including internal identifiers or
personal paths from working context. Express necessary constraints without disclosing private
project details.

## Handle review replies

Read the feedback against current code and evidence. Answer the technical point directly: the
decision, supporting observation or check, and remaining limitation. Correct disproven claims and
keep that correction out of durable documentation unless the resulting constraint matters.

Use project mechanisms where they fit. Explain a necessary exception with the actual constraint; do
not accept a suggestion solely because it came from a reviewer or claim a fix/check was completed
without evidence. Reply in the relevant thread and contact only relevant reviewers within the
authorized scope. A partial approval verifies only the area the reviewer covered.

## Finish after merge

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

## Final check

- Does the text match the final scope and retain the verified context needed to understand it?
- Are facts, inferences, and unverified claims distinguishable, with evidence valid for this
  revision?
- Are required metadata and template fields present, and are publication details safe for this
  target?
- Can the intended reader understand the decision without reading the conversation?
