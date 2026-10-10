# Agent Tooling Commands

Reference commands for project-scoped skills and other external agent tooling. Global skills are not
installed here: they are pinned flake inputs or live in `agents/skills/`, deployed by Home Manager;
see [skills/README.md](skills/README.md). Do not install global skills with `npx skills add -g`; its
copies collide with the Home Manager links in `~/.agents/skills`.

This repository's own skills live in `.agents/skills/`: they are tracked in git and discovered
automatically, so do not install, overwrite, or remove them with `npx skills`.

## Discover skills from repositories

```bash
# list skills in a repository without installing anything
npx skills add anthropics/skills --list
```

## Optional project skills

Run these commands from the project root. They intentionally omit `-g`, so the skills apply only to
the current project. Check `git status` after installation and commit the generated files only when
the whole team should use them.

```bash
# design distinctive UI and demo pages
npx skills add anthropics/skills --skill 'frontend-design'

# test local web applications with Playwright
npx skills add anthropics/skills --skill 'webapp-testing'

# read, create, edit, or validate PDF files
npx skills add anthropics/skills --skill 'pdf'

# run CodeQL and Semgrep on repositories written in supported languages; not for pure Nix projects
# (CC-BY-SA-4.0: copies and modifications carry attribution and the same license)
npx skills add trailofbits/skills --skill 'codeql' --skill 'semgrep'
```

## Other agent tooling

```bash
# tuios: register it as an MCP server for the harness (read-only, or --mcp-write
# for typing tools); also reports agent state into the tuios pane
tuios integration install opencode --mcp-write
```

References:

- https://github.com/vercel-labs/skills
- https://github.com/Gaurav-Gosain/tuios
- https://github.com/anthropics/skills
- https://github.com/trailofbits/skills
