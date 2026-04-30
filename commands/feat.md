---
description: "Create a DevFlow feature specification and GitHub issue using the portable devflow skill"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git branch:*)
  - Bash(git log:*)
  - Bash(git remote:*)
  - Bash(gh label:*)
  - Bash(gh issue:*)
  - WebSearch
argument-hints:
  - "<feature-name>"
  - "--type=feat|fix|docs|refactor|test|chore"
  - "--priority=low|medium|high|critical"
---

# DevFlow Feature Wrapper

Use the `devflow` skill as the source of truth.

1. Read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/SKILL.md`.
2. Read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/references/feat.md`.
3. Treat `$ARGUMENTS` as the feature-planning request.
4. Follow the feature planning workflow exactly, using Claude Code tools only where allowed by this wrapper.
5. After creating the issue, recommend `/devflow:dev issue#<number>`.
