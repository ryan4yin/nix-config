# Global skills

Agent Skills shared by every agent on this machine, deployed into `~/.agents/skills/<name>` by
[`skills.nix`](../../home/base/tui/agents/skills.nix). They come from two places:

- **Flake inputs** (pinned in `flake.lock`): linked from the Nix store, so an update is a lock bump
  plus a Home Manager switch.
- **This directory** (`agents/skills/<name>/`): skills iterated on locally, linked out-of-store so
  an edit applies on the next agent session; adding or removing one needs a switch.

Repository-scoped skills do not belong here; they live in the owning repository's `.agents/skills/`.

## Skills from flake inputs

| Skill                      | Input               | Source                                                                                    |
| -------------------------- | ------------------- | ----------------------------------------------------------------------------------------- |
| `diagnosing-bugs`          | `mattpocock-skills` | [ryan4yin/mattpocock-skills](https://github.com/ryan4yin/mattpocock-skills) `main` (fork) |
| `domain-modeling`          | `mattpocock-skills` | same                                                                                      |
| `grill-with-docs`          | `mattpocock-skills` | same                                                                                      |
| `grilling`                 | `mattpocock-skills` | same                                                                                      |
| `prototype`                | `mattpocock-skills` | same                                                                                      |
| `research`                 | `mattpocock-skills` | same                                                                                      |
| `retro`                    | `mattpocock-skills` | same                                                                                      |
| `setup-matt-pocock-skills` | `mattpocock-skills` | same                                                                                      |
| `wayfinder`                | `mattpocock-skills` | same                                                                                      |
| `writing-for-agents`       | `mattpocock-skills` | same                                                                                      |
| `i-have-adhd`              | `i-have-adhd`       | [ryan4yin/i-have-adhd](https://github.com/ryan4yin/i-have-adhd) `main` (fork)             |
| `humanizer`                | `humanizer`         | [blader/humanizer](https://github.com/blader/humanizer) `v3.1.0`                          |
| `find-docs`                | `context7`          | [upstash/context7](https://github.com/upstash/context7) commit `522c4db4`                 |
| `ponytail-review`          | `ponytail`          | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) `v5.1.0`            |

Dependencies travel together: `grill-with-docs` and `wayfinder` call `grilling` and
`domain-modeling`; `wayfinder` also calls `research` and `prototype`, and points at
`setup-matt-pocock-skills` for the issue-tracker convention; `retro` calls `writing-for-agents`.

User-invoked skills (`disable-model-invocation: true`, plus `allow_implicit_invocation: false` in
`agents/openai.yaml` for Codex) stay out of the model's skill catalog: `grill-with-docs`,
`wayfinder`, `retro`, `setup-matt-pocock-skills`, and `i-have-adhd`. The global rules embed the
i-have-adhd always-on snippet, so the skill is only needed for its full ruleset.

The global rules take precedence over these skills. In particular, `wayfinder` defaults to GitHub
issues and pushes research branches; both are GitHub writes that need authorization, and a public
repository is the wrong place for an infrastructure decision map.

To update one: review the upstream diff as untrusted input, then `nix flake update <input>` (or move
the pinned tag/commit in `flake.nix`) and check `git diff flake.lock`.

## Skills in this directory

`git-delivery` is maintained here rather than pulled from an input: commit messages, PR text, review
replies, and cleanup after merge, all following the target repository's conventions. Edit it in
place; the change reaches the next agent session without a switch.

A third-party skill starts here only when it is being rewritten. Until then, pin it as a flake input
so the license and provenance stay with the upstream repository and the diff stays reviewable.
