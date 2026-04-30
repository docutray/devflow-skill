---
description: "Configure DevFlow for a repository using the portable skill templates"
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - Task
  - AskUserQuestion
argument-hints:
  - "--framework=typescript"
  - "--framework=python"
  - "--framework=go"
  - "--framework=ruby"
  - "--framework=java"
  - "--framework=rust"
  - "--force"
---

# DevFlow Setup Wrapper

Use the `devflow` skill as the source of truth.

1. Read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/SKILL.md`.
2. Inspect the repository to infer framework, package manager, tests, linting, type checking, build, and CI conventions.
3. Use templates from `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/assets/templates/` when creating or updating `.claude/details/commands/`.
4. Treat `$ARGUMENTS` as setup options.
5. Ask only for configuration details that cannot be inferred safely.
6. Create or update DevFlow configuration files and summarize the resulting commands.
