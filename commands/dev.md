---
description: "Implement a GitHub issue using the portable DevFlow development workflow"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
  - TodoWrite
argument-hints:
  - "issue#<number>"
  - "--branch=custom-name"
  - "--draft"
  - "--auto-tests"
  - "--full-validation"
  - "--worktree"
---

# DevFlow Development Wrapper

Use the `devflow` skill as the source of truth.

1. Read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/SKILL.md`.
2. Read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/references/dev.md`.
3. Treat `$ARGUMENTS` as the issue implementation request.
4. If validation is needed, read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/references/check.md`.
5. Follow the development workflow exactly, using Claude Code tools only where allowed by this wrapper.
6. After creating the PR, recommend `/devflow:review-pr <pr-number>`.
