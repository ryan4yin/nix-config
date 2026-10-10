---
name: find-docs
description: >-
  Look up current documentation and code examples for a library, framework, SDK, CLI tool, or cloud
  service with the Context7 CLI. Use whenever a question names a specific technology — API syntax,
  configuration options, version migrations, library-specific debugging, setup, CLI usage —
  including well-known ones: training data goes stale on these details.
---

# Documentation lookup

`ctx7` is on PATH (Home Manager, from nixpkgs). Run it as it is; the package is Nix-managed, so skip
the `setup` and `upgrade` commands its `--help` advertises.

Two steps: resolve the library ID, then query with it.

```bash
ctx7 library <name> "<query>"
ctx7 docs <libraryId> "<query>"
```

Skip step 1 only when the user supplies an ID as `/org/project` or `/org/project/version`. Add
`--json` to either step when you will parse the output rather than read it.

A query leaves the machine: keep internal identifiers, private-repository paths, and credentials out
of it.

## Step 1: resolve the ID

Pass a `query` every time — it ranks the matches, so it also separates libraries that share a name.
Use the official spelling ("Next.js", not "nextjs"); when results look wrong, retry the name before
rewriting the query.

```bash
ctx7 library "Next.js" "how to set up app router middleware"
```

Each match carries `id`, `title`, `description`, `totalSnippets`, `trustScore`, `benchmarkScore`,
and `versions`. Prefer an exact name match with a high `trustScore` and more `totalSnippets`. When
the user names a version, take the closest entry in `versions` and use `/org/project/version` as the
ID.

Stop after three attempts and use the best match you have. When none is usable, say so and suggest a
sharper name instead of guessing.

## Step 2: query the docs

One topic per `docs` call: split unrelated concepts into separate calls, unless the question is
about how they interact. Describe what to look up in the documentation rather than the task to
complete — `"React useEffect cleanup function with async operations"` ranks, `"hooks"` returns
generic results.

```bash
ctx7 docs /vercel/next.js "how to add middleware"
```

The output is markdown: titled code snippets and prose snippets, each with the source URL it came
from. Cite that URL when the answer rests on it.

## When it fails

Lookups work without a login, at a lower rate limit. On a quota error, tell the user to run
`ctx7 login` themselves; never ask them to paste a token into chat. If they do not authenticate,
answer from training knowledge and say it may be outdated — do not fall back silently.
