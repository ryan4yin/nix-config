# Agent Skills Commands

Reference commands for listing, installing, and updating skills via `npx skills`. Keep the global
set small and install task-specific skills in the relevant project.

## Inspect and update installed skills

```bash
# list all installed skills (project + global)
npx skills list

# list only global skills
npx skills ls -g

# check for updates
npx skills check

# update all installed skills
npx skills update
```

## Discover skills from repositories

```bash
# list skills in a repository
npx skills add anthropics/skills --list
```

## Global baseline

```bash
# structured planning, testing, debugging, review, and verification workflows
npx skills add -g obra/superpowers --skill '*'

# discover task-specific skills when needed
npx skills add -g vercel-labs/skills --skill 'find-skills'
```

`find-docs` is also installed globally from a local source, so it has no upstream install command.

## Optional global skills

```bash
# rewrite prose to sound natural while preserving claims and technical meaning
npx skills add -g blader/humanizer --skill 'humanizer'

# review code for unnecessary abstractions and over-engineering
npx skills add -g DietrichGebert/ponytail --skill 'ponytail-review'

# enable a terse response mode when context or token usage matters
npx skills add -g JuliusBrussee/caveman --skill 'caveman'
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
npx skills add trailofbits/skills --skill 'codeql' --skill 'semgrep'
```

References:

- https://github.com/obra/superpowers
- https://github.com/vercel-labs/skills
- https://github.com/blader/humanizer
- https://github.com/DietrichGebert/ponytail
- https://github.com/JuliusBrussee/caveman
- https://github.com/anthropics/skills
- https://github.com/trailofbits/skills
