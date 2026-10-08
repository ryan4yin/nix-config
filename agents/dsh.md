# dsh (DeepSeek Harness)

dsh boots a _profile_: an ordered stack of patch layers over an empty root entry list. Each bundle
in the profile's `dsh.profile.bundles` contributes one layer, then the profile's own patch, then the
machine-local home patch, then `--patch` overlays. Later layers win, so a row in a later layer
outranks the same row earlier.

| #   | Layer     | Path                                         | Writer          |
| --- | --------- | -------------------------------------------- | --------------- |
| 1   | bundles   | shipped with the profile                     | upstream        |
| 2   | profile   | `$DSH_HOME/profiles/<name>/cordis.patch.yml` | dsh, at runtime |
| 3   | home      | `$DSH_HOME/cordis.patch.yml`                 | you             |
| 4   | `--patch` | whatever the launcher passes                 | you             |

`$DSH_HOME` defaults to `~/.dsh`. The home layer is optional and only read; the profile layer is
written by dsh whenever a setting changes.

A patch row's `config` _replaces_ that row's config object; it does not deep-merge with the
bundle's. Repeat every key you mean to keep — the shipped `agent-loop` row carries `agents: []` for
exactly that reason.

## Which layer owns a setting

`dsh-config-editor` persists Settings UI changes into the profile patch. When a later layer pins the
same row, that save is rejected with `Configuration for "..." is overridden by a home patch` — so a
home-layer row is a promise that the UI can never change that setting again. Keep the home layer for
settings the UI must not own (values that should hold across every profile and surface). Anything
the UI does own — the locale preference, the selected preset, model catalogs and their context
windows — belongs in the profile patch.

## Inspecting the composed result

```sh
dsh <profile> --dump-config          # the composed tree with every layer applied
dsh <profile> --dump-default-config  # the same tree without the home layer or --patch overlays
```

Diffing the two shows exactly what your own patches contribute, which is usually far less than the
patch file suggests. `--dump-config-schema` prints the schema for entries and patches.

## Default model

The `dsh-base` bundle sets `agent-default-model` to the API-key route (`deepseek-official` /
`deepseek-flash`). The account route (`deepseek-account`) never falls back to an API key, so a host
holding only `DEEPSEEK_API_KEY` fails every freshly created session with `ACCOUNT_SIGN_IN_REQUIRED`;
a host that has signed in can pick an account model per session.

## Compaction

The web and desktop surfaces give each agent preset its own compaction service, so a top-level
`compaction-basic` row never reaches a session. The knobs that do reach it are the `contextWindow`
and `maxTokens` of the model on the route.

## Private and local model routes

Endpoints that must not enter a public repository — LAN/self-hosted servers, staging gateways —
belong in the profile patch, extending the base route there:

```yaml
- id: llm-pi-ai
  name: "@deepseek-ai/dsh-llm-pi-ai"
  config:
    providers: { ... }
```

`dsh-llm-pi-ai` registers its built-in providers once, so mount only one instance: a second one
fails with `provider "..." is already declared`. In this repository, `just dsh-web` boots the web
profile through mihomo's mixed port; the recipe explains why the proxy is required.

## History

nix-config used to ship a shared home layer from `home/base/tui/agents/dsh/`, linked to
`~/.dsh/cordis.patch.yml`. It was removed on 2026-10-08 because every row in it sat in the layer
that outranks the Settings UI: the locale preference, the selected preset, and the official model
catalog were all pinned there, so the UI could not save them, while `agent-preset-registry.default`
and most of the catalog only repeated what the bundles already ship. Deployment values that still
differ from the shipped defaults were moved into the untracked profile patch.
