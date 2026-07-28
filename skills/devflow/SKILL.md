---
name: devflow
description: Agile development workflow for AI coding agents. Use for GitHub issue planning, feature specifications, implementation from issues, validation checks, PR review, research, epic planning, or when the user mentions DevFlow commands such as /devflow:feat, /devflow:dev, /devflow:check, /devflow:review-pr, /devflow:research, or /devflow:epic.
license: MIT
compatibility: Works with Agent Skills compatible clients including Codex and Claude Code. Requires git for repository workflows, GitHub CLI for issue/PR workflows, and optional web access for research. OPSX/OpenSpec support is optional and targets @fission-ai/openspec 1.x.
metadata:
  author: docutray
  version: "2.0.1"
---

# DevFlow

DevFlow is a portable workflow for turning ideas into GitHub issues, implementing them, validating changes, and reviewing pull requests with a consistent engineering process.

## Workflow Map

- **Setup/configuration**: read [references/setup.md](references/setup.md) when the user asks to configure DevFlow for a repository, create project-local command details, adapt templates, or mentions `/devflow:devflow-setup`.
- **Feature planning**: read [references/feat.md](references/feat.md) when the user asks to create a feature spec, bug spec, GitHub issue, or mentions `/devflow:feat`.
- **Implementation**: read [references/dev.md](references/dev.md) when the user asks to implement a GitHub issue, open a development branch, create a PR, or mentions `/devflow:dev`.
- **Validation**: read [references/check.md](references/check.md) when the user asks to run tests, lint, type checks, build checks, quality gates, or mentions `/devflow:check`.
- **PR review**: read [references/review-pr.md](references/review-pr.md) when the user asks to review a pull request, validate a PR branch, approve/request changes, or mentions `/devflow:review-pr`.
- **Research**: read [references/research.md](references/research.md) when the user asks to investigate a technology, architecture, requirement, or mentions `/devflow:research`.
- **Epic planning**: read [references/epic.md](references/epic.md) when the user asks to plan a large initiative, split work into phases/issues, or mentions `/devflow:epic`.
- **OpenSpec/OPSX**: read [references/openspec.md](references/openspec.md) before running any `openspec` or `/opsx:*` command, or when configuring OpenSpec for a repository.

## Core Principles

1. Start from the current repository state. Inspect git status, project structure, manifests, CI config, and existing conventions before proposing or changing anything.
2. Prefer GitHub as the planning source of truth when issue/PR workflows are requested. Use `gh` when available and ask for permission or fallback only when required by the client.
3. Keep generated plans and issues implementation-ready: motivation, acceptance criteria, technical approach, affected areas, test strategy, and definition of done.
4. Protect user work. Do not discard uncommitted changes. If branch changes are needed and the workspace is dirty, pause for a concrete user decision or use an isolated worktree when requested.
5. Validate before handoff. Run the configured checks for the project, report failures with specific next actions, and fix issues when the user requested implementation.
6. Use OPSX/OpenSpec only when the repository clearly has it configured (`openspec/config.yaml`) or when the user explicitly asks to enable it. Follow [references/openspec.md](references/openspec.md) for the supported version and command surface.

## Configuration

DevFlow can use project-local detail files when present:

```text
.claude/details/commands/
├── check.md
├── feat.md
├── dev.md
└── review-pr.md
```

For non-Claude clients, treat those files as optional DevFlow configuration documents. If they are missing, infer commands from the repository and document the chosen defaults in your response.

Reusable templates live in [assets/templates](assets/templates). Load a template only when configuring or adapting DevFlow for that framework.

## Gotchas

- Do not assume slash commands exist in every client. In Codex and other Agent Skills clients, execute the referenced workflow directly. This applies to `/opsx:*` as well: Codex gets OpenSpec Agent Skills only, so drive OpenSpec through its CLI.
- Claude Code wrappers may expose `/devflow:*` commands, but this skill is the canonical source of behavior.
- `allowed-tools`, `argument-hints`, `Task`, `AskUserQuestion`, web tool names, and `${CLAUDE_PLUGIN_ROOT}` are Claude Code plugin details; do not rely on them in portable workflows.
- Network access, GitHub authentication, and local dependency installation vary by client. Verify availability before depending on them.
