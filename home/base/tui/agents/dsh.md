# dsh configuration

dsh is installed by this module (`packages.nix`) and configured at runtime, not by Nix. It boots a
profile: an ordered stack of patch layers over an empty root entry list, where later layers win.

| #   | Layer     | Path                                         | Writer          |
| --- | --------- | -------------------------------------------- | --------------- |
| 1   | bundles   | shipped with the profile                     | upstream        |
| 2   | profile   | `$DSH_HOME/profiles/<name>/cordis.patch.yml` | dsh, at runtime |
| 3   | home      | `$DSH_HOME/cordis.patch.yml`                 | you             |
| 4   | `--patch` | whatever the launcher passes                 | you             |

`$DSH_HOME` defaults to `~/.dsh`. Settings UI changes are written to the profile patch; a home-layer
row outranks it, so the UI rejects that setting with
`Configuration for "..." is overridden by a home patch`. This repository therefore ships no home
layer — profile patches are machine-local runtime state, the place for private endpoints (LAN
servers, staging gateways) too, and Nix only installs the CLI.

Three behaviours that are easy to get wrong:

- A patch row's `config` **replaces** the row's config object instead of deep-merging into it.
  Repeat every key you mean to keep; the shipped `agent-loop` row repeats `agents: []` for this
  reason.
- The web and desktop surfaces give each agent preset its own compaction service, so a top-level
  `compaction-basic` row never reaches a session. Compact by setting the route's model
  `contextWindow` and `maxTokens` instead.
- `dsh-llm-pi-ai` registers its providers once, so mount only one instance: a second one fails with
  `provider "..." is already declared`.

To see what your own patches actually change:

```sh
dsh <profile> --dump-config          # composed tree with every layer applied
dsh <profile> --dump-default-config  # the same tree without the home layer or --patch overlays
```

The `dsh-base` bundle sets `agent-default-model` to the API-key route (`deepseek-official` /
`deepseek-flash`). The account route never falls back to an API key, so a host holding only
`DEEPSEEK_API_KEY` fails new sessions with `ACCOUNT_SIGN_IN_REQUIRED`.

In this repository, `just dsh-web` boots the web profile through mihomo's mixed port.
