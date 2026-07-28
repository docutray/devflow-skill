---
description: "Create a DevFlow epic plan with phases, GitHub issues, and optional epic branch"
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
  - Task
argument-hints:
  - "<epic-name>"
  - "--priority=low|medium|high|critical"
  - "--target-version=X.Y.Z"
  - "--worktree"
---

# DevFlow Epic Wrapper

Use the `devflow` skill as the source of truth.

1. Read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/SKILL.md`.
2. Read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/references/epic.md`.
3. Treat `$ARGUMENTS` as the epic planning request.
4. Follow the epic planning workflow exactly, using Claude Code tools only where allowed by this wrapper.
5. After creating sub-issues, follow the skill's workflow handoff and recommend the DevFlow development workflow for the first issue, offering `/devflow:dev issue#<number>` as the Claude Code shortcut.
