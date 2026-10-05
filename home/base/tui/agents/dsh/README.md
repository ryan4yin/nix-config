# dsh

The dsh (DeepSeek Harness) `web` profile, linked into `~/.dsh/profiles/web` from the checked-in
files under [`web/`](./web).

## Why the link targets the directory

dsh persists Settings through `cordis.patch.yml` with an atomic write (a random-suffix sibling, then
a rename), and that rename replaces a symlinked target instead of writing through to its referent. A
file-level link — store or out-of-store — is destroyed by the first Settings save, while a directory
link keeps the write inside the checkout. Same reasoning as `home/base/tui/tuios`, one level up.

| Profile member        | Tracked | Role                                       |
| --------------------- | ------- | ------------------------------------------ |
| `cordis.patch.yml`    | yes     | the user patch layer the Settings UI edits |
| `package.json`        | yes     | the profile's `dsh.profile.bundles` list   |
| `pnpm-workspace.yaml` | yes     | the profile's pnpm settings                |
| `cordis.yml`          | no      | rewritten on every boot                    |
| `node_modules/`       | no      | written by `dsh plugin --profile web ...`  |

`web/.gitignore` owns the untracked rows. As with the rules links in the parent module, the
trade-off is a config that stays writable in the checkout: a Settings change and a commit are the
same edit, and the configuration is shared by every host that deploys the profile.

## Which hosts deploy it

A host only gets this link by importing the module. `home/linux/gui.nix` and `home/darwin` pull it
in through `home/base/tui`, so core-only servers miss it — `idols-ruby` installs dsh from
`environment.systemPackages` and imports `home/base/tui/agents/dsh` from its own home module. A new
host that ships dsh needs one of those two wirings.

## Default model route

`web/cordis.patch.yml` pins `agent-default-model` to the API-key route (`deepseek-official`). The
account route (`deepseek-account`) never falls back to an API key, so a host holding only
`DEEPSEEK_API_KEY` fails every freshly created session with `ACCOUNT_SIGN_IN_REQUIRED`. A host that
signs in instead can select an account model per session, or override the field in its own
`$DSH_HOME/cordis.patch.yml`, which the home layer applies last and which therefore wins.

## Running it

`just dsh-web` starts the harness without opening a browser and routes its outbound HTTP through
mihomo's mixed port. dsh's web fetch refuses a DNS answer it does not call public, and a fake-ip
resolver answers with `198.18.0.0/15`; a proxied hop lets mihomo resolve the origin instead, which
skips that check and leaves fake-ip acceleration intact. The policy reaches every Node fetch the
harness makes, so mihomo becomes a dependency for LLM, web search and HTTP MCP traffic too.
