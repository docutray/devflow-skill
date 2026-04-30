---
description: "Research a topic before DevFlow feature or epic planning"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(git status:*)
  - Bash(git log:*)
  - WebSearch
  - WebFetch
  - Task
argument-hints:
  - "<topic>"
  - "--depth=shallow|medium|deep"
  - "--output=summary|detailed|report"
---

# DevFlow Research Wrapper

Use the `devflow` skill as the source of truth.

1. Read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/SKILL.md`.
2. Read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/references/research.md`.
3. Treat `$ARGUMENTS` as the research request.
4. Follow the research workflow exactly, using Claude Code tools only where allowed by this wrapper.
5. Recommend `/devflow:feat` or `/devflow:epic` when research is complete.
