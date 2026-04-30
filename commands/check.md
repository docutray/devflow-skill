---
description: "Run DevFlow validation checks for tests, linting, type checking, build, and optional OPSX/OpenSpec gates"
allowed-tools:
  - Task
  - Bash
  - Read
argument-hints:
  - "--fast"
  - "--verbose"
---

# DevFlow Check Wrapper

Use the `devflow` skill as the source of truth.

1. Read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/SKILL.md`.
2. Read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/references/check.md`.
3. Treat `$ARGUMENTS` as validation options.
4. Run configured or inferred checks. Use parallel Task calls when practical in Claude Code.
5. Return the validation report in the format defined by the skill reference.
