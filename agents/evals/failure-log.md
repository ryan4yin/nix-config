# Failure log

Recurring agent failures seen in real sessions, with rough frequency and cost to the user, so rule
and scenario work goes where it pays. Each review adds a dated section. Keep it aggregate: no
session content, private repository, host, or person names. Concrete cases become
[scenarios](global-rules.md); the counts stay here.

## 2026-10-18 to 2026-11-10

267 sessions and about 3,500 user messages, mostly on `deepseek-flash`, `claude-opus-5-5`, and
`gpt-6-astra`. Each of about 600 user corrections was checked against the agent's preceding turn.
Counts are approximate, and one correction can fall in two rows. Ordered by count times cost:

| Failure                                                        | Count       | Cost to the user                      |
| -------------------------------------------------------------- | ----------- | ------------------------------------- |
| Verbose comments, docs, commit and PR text; over-trimmed later | ~130        | Corrected on most commits             |
| Narrow or local patch where a shared or upstream fix existed   | ~105        | Finished PRs reworked                 |
| Unverified claims stated as fact                               | ~100        | One benchmark series discarded        |
| Investigating instead of answering; long silent turns          | ~90         | 63 turns over 30 minutes              |
| Credential, publishing, or push boundary crossed               | ~60         | Highest per incident                  |
| Fixed `sleep` waits; one failing approach retried many times   | 1,135 calls | Minutes-long tasks taking hours       |
| Editing when asked a question; continuing after "stop"         | ~30         | Unwanted changes to revert            |
| Over-testing a low-risk change                                 | ~20         | Half-minute edits taking hours        |
| Preferences from earlier sessions forgotten                    | ~16         | Same correction repeated across weeks |

The user named Grice's maxims or Occam's razor in chat at least 15 times to get shorter text, and
asked "what are you doing" or "report first" 77 times.

Two measurements show why rules that already existed did not help:

- Skills loaded on demand rarely loaded: about a quarter of commits ran with `git-delivery` loaded,
  and `review-comments-and-docs` loaded in 17 of 267 sessions. Writing caps that lived only in those
  skills mostly never applied, so the rules now carry them.
- Fixed sleeps as a share of tool calls: `k3.1-pro` 14%, `claude-opus-5-5` 4.5%, `deepseek-flash`
  2.2%, `gpt-6-astra` under 0.1%. The rule against them had been in place throughout; harness
  enforcement is an [open item](../README.md#todo).
