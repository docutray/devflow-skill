---
description: "Review a pull request using the portable DevFlow PR review workflow"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(git status:*)
  - Bash(git worktree list:*)
  - Bash(gh pr view:*)
  - Bash(gh pr diff:*)
  - Bash(gh pr checks:*)
  - Bash(gh issue view:*)
  - Task
argument-hint: "<pr-number> [--fix-issues] [--run-full-suite] [--auto-approve] [--post] [--functional-tests] [--skip-functional] [--worktree]"
---

# DevFlow PR Review Wrapper

Use the `devflow` skill as the source of truth.

1. Read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/SKILL.md`.
2. Read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/references/review-pr.md`.
3. Treat `$ARGUMENTS` as the pull request review request.
4. If validation is needed, read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/references/check.md`.
5. Follow the PR review workflow exactly.
