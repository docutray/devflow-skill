---
description: "Configure DevFlow for a repository using the portable skill templates"
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash(git status:*)
  - Bash(git log:*)
  - Bash(git branch:*)
  - Bash(git remote:*)
  - Bash(git ls-files:*)
  - Bash(ls:*)
  - Bash(openspec --version)
  - Task
  - AskUserQuestion
argument-hint: "[--framework=typescript|python|go|ruby|java|rust] [--force]"
---

# DevFlow Setup Wrapper

Use the `devflow` skill as the source of truth.

1. Read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/SKILL.md`.
2. Read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/references/setup.md`.
3. Treat `$ARGUMENTS` as setup options.
4. Follow the setup workflow exactly, using templates from `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/assets/templates/` only when useful.
5. Ask only for configuration details that cannot be inferred safely.
6. Create or update DevFlow configuration files and summarize the resulting commands.
