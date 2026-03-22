# Agent Skills Commands

Reference commands for listing, installing, and updating skills via `npx skills`. Run only the
commands you need.

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

# remove from global scope
npx skills remove --global web-design-guidelines
```

## Discover skills from repositories

```bash
# list skills in a repository
npx skills add vercel-labs/agent-skills --list
```

## Install commonly used skill packs

```bash
# superpowers
npx skills add -g obra/superpowers --agent '*' --skill '*'

# github skills
npx skills add -g github/awesome-copilot --agent '*' --skill 'git-commit' --skill 'gh-cli'

# find skills
npx skills add -g vercel-labs/skills --agent '*'

# anthropic skills
npx skills add -g anthropics/skills --agent '*' --skill 'skill-creator' --skill 'pdf'
```

## Optional packs

```bash
npx skills add -g pbakaus/impeccable --agent '*' --skill '*'

npx skills add -g coreyhaines31/marketingskills --agent '*' --skill '*'

npx skills add -g phuryn/pm-skills --agent '*' --skill '*'
```

References:

- https://github.com/vercel-labs/skills
- https://github.com/pbakaus/impeccable
- https://github.com/coreyhaines31/marketingskills
- https://github.com/phuryn/pm-skills
