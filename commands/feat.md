---
description: "Create a DevFlow feature specification and GitHub issue using the portable devflow skill"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(git status:*)
  - Bash(git branch --show-current)
  - Bash(git remote -v)
  - Bash(gh label list:*)
  - Bash(gh issue view:*)
  - Bash(gh issue list:*)
  - WebSearch
argument-hint: "<feature-name> [--type=feat|fix|docs|refactor|test|chore] [--priority=low|medium|high|critical]"
---

# DevFlow Feature Wrapper

Use the `devflow` skill as the source of truth.

1. Read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/SKILL.md`.
2. Read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/references/feat.md`.
3. Treat `$ARGUMENTS` as the feature-planning request.
4. Follow the feature planning workflow exactly.
5. After creating the issue, follow the skill's workflow handoff and recommend the DevFlow development workflow, offering `/devflow:dev issue#<number>` as the Claude Code shortcut.
