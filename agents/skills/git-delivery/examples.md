# Git delivery examples

Messages and guidance quoted from widely followed sources, with notes on what to take from each.
Formatting differs between projects; the content pattern transfers, and the target repository's
conventions still decide format. Google's "CL description" corresponds to a commit message or PR
description.

Contents:

- [Subject only](#subject-only)
- [Subjects that say too little](#subjects-that-say-too-little)
- [A small change that still needs context](#a-small-change-that-still-needs-context)
- [Explain why, not how](#explain-why-not-how)
- [A behavior change and its cost](#a-behavior-change-and-its-cost)
- [Explain a removal and add trailers](#explain-a-removal-and-add-trailers)
- [Point at the commit being fixed](#point-at-the-commit-being-fixed)
- [Permanent record versus review notes](#permanent-record-versus-review-notes)
- [Evidence after the code changes](#evidence-after-the-code-changes)
- [Disagreeing with a reviewer](#disagreeing-with-a-reviewer)

## Subject only

```text
Fix typo in introduction to user guide
```

```text
docs: correct spelling of CHANGELOG
```

The same kind of change in a plain and a Conventional Commits repository. Nothing more is needed; a
reader who wants the typo can run `git show`. Sources: [cbeams][cbeams], [Conventional Commits][cc].

## Subjects that say too little

Google lists these real descriptions as inadequate: "Fix bug", "Fix build.", "Add patch.", "Moving
code from A to B.", "Phase 1.", "Add convenience functions.", "kill weird URLs." None says what
changed or why. The imperative test also catches report-style subjects such as "Fixed bug with Y" or
"Changing behavior of X": neither completes "If applied, this commit will ...". The same applies to
a PR titled "Address review feedback". Sources: [Google][google-cl], [cbeams][cbeams].

## A small change that still needs context

```text
Create a Python3 build rule for status.py.

This allows consumers who are already using this as in Python3 to
depend on a rule that is next to the original status build rule
instead of somewhere in their own tree. It encourages new consumers
to use Python3 if they can, instead of Python2, and significantly
simplifies some automated build file refactoring tools being worked
on currently.
```

The diff is a few lines of build configuration. Who benefits and why exists only in the body. Keep
this context however small the patch is. Source: [Google][google-cl].

## Explain why, not how

```text
Simplify serialize.h's exception handling

Remove the 'state' and 'exceptmask' from serialize.h's stream
implementations, as well as related methods.

As exceptmask always included 'failbit', and setstate was always
called with bits = failbit, all it did was immediately raise an
exception. Get rid of those variables, and replace the setstate
with direct exception throwing (which also removes some dead
code).

As a result, good() is never reached after a failure (there are
only 2 calls, one of which is in tests), and can just be replaced
by !eof().

fail(), clear(n) and exceptions() are just never called. Delete
them.
```

Each paragraph states a fact a reviewer can check against the diff and justifies a deletion that a
future maintainer might otherwise question. Source: [Bitcoin Core eb0b56b][bitcoin], cited by
[cbeams][cbeams].

## A behavior change and its cost

```text
RPC: Remove size limit on RPC server message freelist.

Servers like FizzBuzz have very large messages and would benefit
from reuse. Make the freelist larger, and add a goroutine that frees
the freelist entries slowly over time, so that idle servers
eventually release all freelist entries.
```

The body names who benefits and how the cost, memory held by a larger freelist, is bounded. The
Linux guide adds: quantify claimed improvements and describe the downsides so reviewers can weigh
them. Sources: [Google][google-cl], [Linux][linux].

## Explain a removal and add trailers

```text
fix: prevent racing of requests

Introduce a request id and a reference to latest request. Dismiss
incoming responses other than from latest request.

Remove timeouts which were used to mitigate the racing issue but are
obsolete now.

Reviewed-by: Z
Refs: #123
```

The second paragraph explains a deletion that might otherwise be restored. Trailers follow the body
in `Token: value` form. Source: [Conventional Commits][cc].

## Point at the commit being fixed

```text
Commit e21d2170f36602ae2708 ("video: remove unnecessary
platform_set_drvdata()") removed the unnecessary
platform_set_drvdata(), but left the variable "dev" unused,
delete it.
```

```text
Fixes: 54a4f0239f2e ("KVM: MMU: make kvm_mmu_zap_page() return the number of pages it actually freed")
```

A hash with its subject identifies the commit without a lookup, and `Fixes:` helps backporting.
Trailer vocabulary is project-specific: Git itself does not use `Fixes:` or `Link:`, and cites
commits as `f86a374 (pack-bitmap.c: fix a memleak, 2015-03-30)`. Sources: [Linux][linux],
[Git][git].

## Permanent record versus review notes

```text
<commit message>
...
Signed-off-by: Author <author@mail>
---
V2 -> V3: Removed redundant helper function
V1 -> V2: Cleaned up coding style and addressed review comments
```

Linux patch mail puts reviewer-only notes below `---`, which is stripped when the patch is applied.
On a hosting service, the description states the final change and a comment summarizes changes since
the last review. Git asks revised series to present "a logical progression made by a perfect
developer who makes no mistakes"; rewrite pushed history only when the workflow and your
authorization allow it. Sources: [Linux][linux], [Git][git].

## Evidence after the code changes

Linux removes `Tested-by:` and `Reviewed-by:` tags when a later version "has changed substantially",
because they described the earlier version. Apply the same rule to your own verification claims. An
illustrative PR section:

```text
Verification (at 3f2c1ab):
- Unit and integration tests pass on Linux x86_64.
- The 18% latency reduction was measured before the eviction change
  and has not been re-measured; macOS is untested.
```

Source: [Linux][linux].

## Disagreeing with a reviewer

```text
Bad:  No, I'm not going to do that.

Good: I went with X because of [these pros/cons] with [these
      tradeoffs]. My understanding is that using Y would be worse
      because of [these reasons]. Are you suggesting that Y better
      serves the original tradeoffs, that we should weigh the
      tradeoffs differently, or something else?
```

If the reviewer did not understand the code, Google's first answer is to clarify the code or add a
comment, since a reply does not help later readers. Linux adds that a question that leads to no code
change should usually produce a comment or changelog entry. Sources: [Google][google-review],
[Linux][linux].

[cbeams]: https://cbea.ms/git-commit/
[cc]: https://www.conventionalcommits.org/en/v1.0.0/
[google-cl]: https://google.github.io/eng-practices/review/developer/cl-descriptions.html
[google-review]: https://google.github.io/eng-practices/review/developer/handling-comments.html
[bitcoin]: https://github.com/bitcoin/bitcoin/commit/eb0b56b19017ab5c16c745e6da39c53126924ed6
[linux]: https://www.kernel.org/doc/html/latest/process/submitting-patches.html
[git]: https://git-scm.com/docs/SubmittingPatches
