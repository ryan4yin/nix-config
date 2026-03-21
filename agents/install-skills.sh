# https://github.com/vercel-labs/skills

# List all installed skills (project and global)
npx skills list

# List only global skills
npx skills ls -g

# Check if any installed skills have updates
npx skills check

# Update all skills to latest versions
npx skills update

# Remove from global scope
npx skills remove --global web-design-guidelines

# =========================================

# List skills in a repository
npx skills add vercel-labs/agent-skills --list

# superpowers
npx skills add -g obra/superpowers --agent '*' --skill '*'
# github skills
npx skills add -g github/awesome-copilot --agent '*' --skill 'git-commit'
# find skills
npx skills add -g vercel-labs/skills --agent '*'
# skill-creator
npx skills add -g anthropics/skills --agent '*' --skill 'skill-creator' 

# frontend
# https://github.com/pbakaus/impeccable
# npx skills add -g pbakaus/impeccable --agent '*' --skill '*' 

# https://github.com/coreyhaines31/marketingskills
# npx skills add -g coreyhaines31/marketingskills --agent '*' --skill '*'

# https://github.com/phuryn/pm-skills
# npx skills add -g phuryn/pm-skills --agent '*' --skill '*'

