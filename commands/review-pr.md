---
description: "Review a pull request using the portable DevFlow PR review workflow"
allowed-tools:
  - Read
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
argument-hints:
  - "<pr-number>"
  - "--fix-issues"
  - "--run-full-suite"
  - "--auto-approve"
  - "--functional-tests"
  - "--skip-functional"
  - "--worktree"
---

# DevFlow PR Review Wrapper

Use the `devflow` skill as the source of truth.

1. Read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/SKILL.md`.
2. Read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/references/review-pr.md`.
3. Treat `$ARGUMENTS` as the pull request review request.
4. If validation is needed, read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/references/check.md`.
5. Follow the PR review workflow exactly, using Claude Code tools only where allowed by this wrapper.
