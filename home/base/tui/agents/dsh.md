# dsh configuration

dsh is installed by this module (`packages.nix`) and configured at runtime, not by Nix. It boots a
profile: an ordered stack of patch layers over an empty root entry list, where later layers win.

| #   | Layer     | Path                                         | Writer          |
| --- | --------- | -------------------------------------------- | --------------- |
| 1   | bundles   | shipped with the profile                     | upstream        |
| 2   | profile   | `$DSH_HOME/profiles/<name>/cordis.patch.yml` | dsh, at runtime |
| 3   | home      | `$DSH_HOME/cordis.patch.yml`                 | you             |
| 4   | `--patch` | whatever the launcher passes                 | package wrapper |

`$DSH_HOME` defaults to `~/.dsh`. Settings UI changes are written to the profile patch; a home-layer
row outranks it, so the UI rejects that setting with
`Configuration for "..." is overridden by a home patch`. This repository ships no home layer:
profile patches remain machine-local runtime state, the place for private endpoints (LAN servers,
staging gateways) too. The shell swap is a package concern instead: Nix installs `dsh` from
`nur-ryan4yin` with `dsh.withPlugins`, which adds a `--patch` overlay after the profile layer.

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

## Global rules

`dsh-base` already mounts `dsh-agent-instructions` (`maxBytes: 65536`) and `rules.nix` links
`agents/global-rules.md` into both scopes it reads — `$DSH_HOME/AGENTS.md` and, from `0.2.1-alpha.2`
on, `$DSH_AGENTS_HOME/AGENTS.md` — so no patch row is needed; identical content renders once.

- The scopes come from the environment: `0.2.1-alpha.2` removed the row's `dshHome` / `agentsHome`.
- Nested `AGENTS.md` files are discovered by `read` / `write` / `edit`, not by `cd` inside `bash`,
  and nothing is watched: an external edit lands on the next such call, or on resume.

## Nushell-only shell

`nur-ryan4yin`'s `dsh.withPlugins [ ...dsh-nushell-only ]` replaces the two first-party shell
providers with Nushell: every `ctx.shell` consumer (model shell tools, background jobs, hook
bridges, in-process callers) runs `nu --no-config-file -c`, and a command that hands execution to
another shell is refused before it spawns. The plugin adds Nushell rules and a syntax guide, and
rewrites the shell-tool descriptions, so the model is told what actually runs. `nu` comes from the
NUR package, so it does not depend on `PATH`.

The source is the `develop` branch of ryan4yin's fork carrying the reviewed patch set (Nu-builtin
denial facts, test-harness fixes, the `find` hint, persistent-terminal scoping), pinned by
`fetchFromGitHub` and `hashes.json` in `nur-packages`; nix-config locks that package set in its
`flake.lock`. `dsh.withPlugins` wraps the binary: each invocation gets a generated `--patch <file>`
overlay after the profile layer, while `dsh plugin` stays untouched. No `$DSH_HOME/cordis.patch.yml`
is written, so there is no home-layer state to resolve or roll back. Boundaries: preset rows that
spawn a shell themselves (`custom-bash.mjs`, `persistent-shell`) bypass `ctx.shell`. So does
`@deepseek-ai/dsh-experimental-terminal-bundle`: its `terminal_*` tools use a separate
`ctx.terminals` seam and run the platform shell (bash on the POSIX hosts this repository manages),
so they coexist with this plugin but stay outside the Nushell-only guarantee — keep the bundle off
for a strict Nu-only machine (the fork's `--with-terminal-bundle` integration run covers the
coexistence). Bash hooks now run under Nushell and need rewriting; remote hosts still run their own
POSIX shell. Rollback: install plain `dsh` or pass an empty plugin list; there is no home file to
delete. Tested on Linux; the same package also builds for Darwin, where it has not been boot-tested.

Verify after a switch:

```sh
dsh web --dump-config | grep -n "nushell"
# expect the first-party shell rows disabled, nushell-executor and nushell-teaching inserted
dsh web 2>&1 | grep "disabling profile plugin"
# a dsh bump can disable a row whose manifest no longer matches; nothing prints when healthy
```
