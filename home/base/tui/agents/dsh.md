# dsh configuration

dsh is installed by this module (`packages.nix`) and configured at runtime, not by Nix. It boots a
profile: an ordered stack of patch layers over an empty root entry list, where later layers win.

| #   | Layer   | Path                                         | Writer          |
| --- | ------- | -------------------------------------------- | --------------- |
| 1   | bundles | shipped with the profile                     | upstream        |
| 2   | profile | `$DSH_HOME/profiles/<name>/cordis.patch.yml` | dsh, at runtime |
| 3   | home    | `$DSH_HOME/cordis.patch.yml`                 | you             |

`$DSH_HOME` defaults to `~/.dsh`. Settings UI changes are written to the profile patch; a home-layer
row outranks it, so the UI rejects that setting with
`Configuration for "..." is overridden by a home patch`. This repository ships no home layer:
profile patches remain machine-local runtime state, the place for private endpoints (LAN servers,
staging gateways) too. Nix installs plain `dsh` from `nur-ryan4yin`, with no package wrapper and no
`--patch` overlay.

Five behaviours that are easy to get wrong:

- A patch row's `config` **replaces** the row's config object instead of deep-merging into it.
  Repeat every key you mean to keep; the shipped `agent-loop` row repeats `agents: []` for this
  reason.
- The web and desktop surfaces give each agent preset its own compaction service, so a top-level
  `compaction-basic` row never reaches a session. Compact by setting the route's model
  `contextWindow` and `maxTokens` instead.
- `dsh-llm-pi-ai` registers its providers once, so mount only one instance: a second one fails with
  `provider "..." is already declared`.
- A patch row matches its bundle row by `id` and must repeat that row's exact `name`. Pointing the
  row at a local plugin file instead makes dsh skip the whole row with
  `patch: name mismatch for "..."`, which silently drops everything the row configured: an
  `llm-pi-ai` row lost this way takes every custom provider route out of the picker, leaving only
  the `dsh-base` default model. To run a patched adapter, set `disabled: true` on the bundle row and
  `insert` the replacement under a different id.
- A provider route has no service-tier knob: `dsh-llm-pi-ai` through 0.2.2-rc.3 accepts no
  `serviceTier` and offers no payload hook, even though the pi-ai it bundles sends `service_tier`.
  Only a patched adapter can set it, and the `openai` / `openai-re` gateways then answer
  `service_tier: priority` with `service_tier: default` while rejecting unknown values
  (`Unsupported service_tier: flex`), so the tier is not something these routes can select.

To see what your own patches actually change:

```sh
dsh <profile> --dump-config          # composed tree with every layer applied
dsh <profile> --dump-default-config  # the same tree without the home layer or --patch overlays
```

The `dsh-base` bundle sets `agent-default-model` to the API-key route (`deepseek-official` /
`deepseek-flash`). The account route never falls back to an API key, so a host holding only
`DEEPSEEK_API_KEY` fails new sessions with `ACCOUNT_SIGN_IN_REQUIRED`.

In this repository, `just dsh-web` boots the web profile through mihomo's mixed port.

## Global rules

`dsh-base` already mounts `dsh-agent-instructions` (`maxBytes: 65536`) and `rules.nix` links
`agents/global-rules.md` into both scopes it reads — `$DSH_HOME/AGENTS.md` and, from `0.2.1-alpha.2`
on, `$DSH_AGENTS_HOME/AGENTS.md` — so no patch row is needed; identical content renders once.

- The scopes come from the environment: `0.2.1-alpha.2` removed the row's `dshHome` / `agentsHome`.
- Nested `AGENTS.md` files are discovered by `read` / `write` / `edit`, not by `cd` inside `bash`,
  and nothing is watched: an external edit lands on the next such call, or on resume.
