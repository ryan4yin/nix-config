# dsh

Shared dsh (DeepSeek Harness) policy, linked into `~/.dsh/cordis.patch.yml`.

## Layers

dsh composes a profile from bundle patches, the profile's own `cordis.patch.yml`, then
`$DSH_HOME/cordis.patch.yml` (the "home" layer) and `--patch` overlays. The home layer is the only
one shared by every profile and surface, so the stable policy lives here.

| Layer   | Path                                      | Writer                        | Tracked |
| ------- | ----------------------------------------- | ----------------------------- | ------- |
| home    | `~/.dsh/cordis.patch.yml`                 | nix-config; dsh only reads it | yes     |
| profile | `~/.dsh/profiles/<name>/cordis.patch.yml` | dsh, at runtime               | no      |

dsh writes the profile patch but only reads the home layer, so linking the home layer is safe while
linking the profile patch would put runtime state in the checkout. Declared settings are edited
here, not in the Settings UI.

## Which hosts deploy it

A host only gets this link by importing the module. `home/linux/gui.nix` and `home/darwin` pull it
in through `home/base/tui`, so core-only servers miss it — `idols-ruby` installs dsh from
`environment.systemPackages` and imports `home/base/tui/agents/dsh` from its own home module. A new
host that ships dsh needs one of those two wirings.

## Default model route

`cordis.patch.yml` pins `agent-default-model` to the API-key route (`deepseek-official`). The
account route (`deepseek-account`) never falls back to an API key, so a host holding only
`DEEPSEEK_API_KEY` fails every freshly created session with `ACCOUNT_SIGN_IN_REQUIRED`. A host that
signs in instead can select an account model per session.

## Compaction

The web and desktop surfaces give each agent preset its own compaction service, so a top-level
`compaction-basic` row here never reaches a session. The effective knobs are the model
`contextWindow` and `maxTokens`: the `400000`/`32000` values set here place the first compaction
near 300k tokens.

## Private and local model routes

Endpoints that must not enter this repository — LAN/self-hosted servers and staging gateways — do
not belong in the home layer. Declare them locally as a separate pi-ai instance in the profile
patch, which dsh does not deploy from here:

```yaml
# ~/.dsh/profiles/<name>/cordis.patch.yml
- insert:
    - id: llm-pi-ai-private
      name: "@deepseek-ai/dsh-llm-pi-ai"
      config:
        providers: { ... }
```

The private instance coexists with the shared one under its own id.

## Running it

`just dsh-web` starts the harness without opening a browser and routes its outbound HTTP through
mihomo's mixed port. dsh's web fetch refuses a DNS answer it does not call public, and a fake-ip
resolver answers with `198.18.0.0/15`; a proxied hop lets mihomo resolve the origin instead, which
skips that check and leaves fake-ip acceleration intact. The policy reaches every Node fetch the
harness makes, so mihomo becomes a dependency for LLM, web search and HTTP MCP traffic too.
