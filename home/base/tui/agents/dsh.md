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

`dsh-nu`'s flake builds the bundle and `nur-ryan4yin`'s `dsh.withPlugins` applies it: every
`ctx.shell` consumer (model shell tools, background jobs, hook bridges, in-process callers) runs
`nu --no-config-file -c`, and a command that hands execution to another shell is refused before it
spawns. The plugin adds Nushell rules and a syntax guide, and rewrites the shell-tool descriptions,
so the model is told what actually runs. `nu` is the Nushell `dsh-nu`'s flake resolves — Nixpkgs',
through `inputs.nixpkgs.follows` — substituted into the rendered patch at build time, so it does not
depend on `PATH`. The bundle still records Nushell 0.115.1 as its tested release; nix-config follows
the main nixpkgs and rewrites that manifest field to the resolved Nushell in `outputs/default.nix`
until dsh-nu retests, rather than pinning an older nixpkgs for the whole plugin. A command that
hands a script file to a shell (`bash scripts/build.sh`) is refused, and the refusal names the
direct `./scripts/build.sh` spelling; the guard itself is unchanged.

`home/base/tui/agents/packages.nix` calls `dsh-nu.lib.mkDshNuPackage { inherit pkgs dsh; }` and
passes the result to `withPlugins`; `flake.lock` pins both inputs. `dsh.withPlugins` wraps the
binary: each invocation gets a generated `--patch <file>` overlay after the profile layer, while
`dsh plugin` stays untouched. No `$DSH_HOME/cordis.patch.yml` is written, so there is no home-layer
state to resolve or roll back. Boundaries: preset rows that spawn a shell themselves
(`custom-bash.mjs`, `persistent-shell`) bypass `ctx.shell`. So does
`@deepseek-ai/dsh-experimental-terminal-bundle`: its `terminal_*` tools use a separate
`ctx.terminals` seam and run the platform shell (bash on the POSIX hosts this repository manages),
so they coexist with this plugin but stay outside the Nushell-only guarantee — keep the bundle off
for a strict Nu-only machine. Bash hooks now run under Nushell and need rewriting; remote hosts
still run their own POSIX shell. Rollback: install plain `dsh` or pass an empty plugin list; there
is no home file to delete. Tested on Linux; the same package also builds for Darwin, where it has
not been boot-tested.

Verify after a switch:

```sh
dsh --profile web --dump-config | grep -nE 'nu-executor|nu-teaching'
# expect the first-party shell rows disabled, nu-executor and nu-teaching inserted
```

A dsh bump can disable a row whose manifest no longer matches. That compatibility check runs only
when a profile boots, not under the boot-free `--dump-config`, so read the stderr of the next boot
(for example `just dsh-web`) for `disabling profile plugin`; nothing prints when healthy.
