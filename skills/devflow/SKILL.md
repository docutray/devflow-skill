---
name: devflow
description: Agile development workflow for AI coding agents, usable from Codex, Claude Code, and any Agent Skills client. Use when the user asks to plan a GitHub issue, write a feature or bug specification, implement an issue, run validation checks, review a pull request, research a topic, or plan an epic. Also triggered by phrasing such as "use DevFlow to ..." or by the optional Claude Code commands /devflow:feat, /devflow:dev, /devflow:check, /devflow:review-pr, /devflow:research, /devflow:epic, and /devflow:devflow-setup.
license: MIT
compatibility: Works with Agent Skills compatible clients including Codex and Claude Code. Requires git for repository workflows, GitHub CLI for issue/PR workflows, and optional web access for research. OPSX/OpenSpec support is optional and targets @fission-ai/openspec 1.x.
metadata:
  author: docutray
  version: "2.2.0"
---

# DevFlow

DevFlow is a portable workflow for turning ideas into GitHub issues, implementing them, validating changes, and reviewing pull requests with a consistent engineering process.

## Invocation And Clients

This skill is the interface. Codex and Claude Code are equally supported: every workflow below behaves identically in either, driven by natural language.

- **Any Agent Skills client, including Codex**: state the intent, for example "Use DevFlow to implement issue #123".
- **Claude Code**: the same natural language works. The `/devflow:*` slash commands are an optional convenience wrapper that reads this skill and adds no behavior of its own.

Never require a slash command, never treat one as a workflow's canonical name, and never tell a user something is unavailable because their client has no `/devflow:*` commands.

## Workflow Map

- **Setup/configuration**: read [references/setup.md](references/setup.md) when the user asks to configure DevFlow for a repository, create project-local workflow configuration, adapt templates, or mentions `/devflow:devflow-setup`.
- **Feature planning**: read [references/feat.md](references/feat.md) when the user asks to create a feature spec, bug spec, GitHub issue, or mentions `/devflow:feat`.
- **Implementation**: read [references/dev.md](references/dev.md) when the user asks to implement a GitHub issue, open a development branch, create a PR, or mentions `/devflow:dev`.
- **Validation**: read [references/check.md](references/check.md) when the user asks to run tests, lint, type checks, build checks, quality gates, or mentions `/devflow:check`.
- **PR review**: read [references/review-pr.md](references/review-pr.md) when the user asks to review a pull request, validate a PR branch, approve/request changes, or mentions `/devflow:review-pr`.
- **Research**: read [references/research.md](references/research.md) when the user asks to investigate a technology, architecture, requirement, or mentions `/devflow:research`.
- **Epic planning**: read [references/epic.md](references/epic.md) when the user asks to plan a large initiative, split work into phases/issues, or mentions `/devflow:epic`.
- **OpenSpec/OPSX**: read [references/openspec.md](references/openspec.md) before running any `openspec` or `/opsx:*` command, or when configuring OpenSpec for a repository.

## Workflow Handoffs

Every workflow ends by recommending what comes next. Name the DevFlow workflow, never a slash command:

| Finished | Recommend next |
|---|---|
| Setup | Feature planning, or implementation if issues already exist |
| Research | Feature planning, or epic planning for a large initiative |
| Epic planning | Feature planning for the first phase, then implementation |
| Feature planning | Implementation for the issue just created |
| Implementation | PR review for the pull request just opened |
| Validation | Return to the calling workflow; on failure, give concrete next actions |
| PR review | Merge, or implementation again when changes were requested |

Phrase the handoff so it works in any client: "Next: use the DevFlow development workflow for issue #123." In Claude Code you may append the `/devflow:dev issue#123` shortcut in parentheses, but never as the only form.

## Core Principles

1. Start from the current repository state. Inspect git status, project structure, manifests, CI config, and existing conventions before proposing or changing anything.
2. Prefer GitHub as the planning source of truth when issue/PR workflows are requested. Use `gh` when available and ask for permission or fallback only when required by the client.
3. Keep generated plans and issues implementation-ready: motivation, acceptance criteria, technical approach, affected areas, test strategy, and definition of done.
4. Protect user work. Do not discard uncommitted changes. If branch changes are needed and the workspace is dirty, pause for a concrete user decision or use an isolated worktree when requested.
5. Validate before handoff. Run the configured checks for the project, report failures with specific next actions, and fix issues when the user requested implementation.
6. Use OPSX/OpenSpec only when the repository clearly has it configured (`openspec/config.yaml`) or when the user explicitly asks to enable it. Follow [references/openspec.md](references/openspec.md) for the supported version and command surface.

## Configuration

DevFlow reads optional project-local configuration. The canonical location is client-neutral:

```text
.devflow/
├── check.md
├── feat.md
├── dev.md
└── review-pr.md
```

Resolution order, first match wins per file:

1. `.devflow/<workflow>.md` — canonical, works in every client.
2. `.claude/details/commands/<workflow>.md` — legacy location from DevFlow 2.0 and earlier. Still read for backward compatibility.

The file names match the workflows: `check.md` for validation, `dev.md` for implementation, `feat.md` for feature planning, `review-pr.md` for PR review.

Never create a new file in the legacy location. When a repository already keeps a workflow's configuration there, edit that file in place so the repository keeps a single source of truth, and offer migration to `.devflow/` rather than performing it. Everything else goes to `.devflow/`. If neither location has the file, infer commands from the repository and state the chosen defaults in your response.

Worktrees follow the same rule: prefer `.devflow/worktrees/`, and respect `.claude/worktrees/` when the repository already uses it.

`.devflow/` holds both committed configuration and ignored scratch space, so scope the ignore rule precisely. Ignore `.devflow/worktrees/`, never `.devflow/` as a whole, which would drop the project's configuration from version control.

Reusable templates live in [assets/templates](assets/templates). Load a template only when configuring or adapting DevFlow for that framework.

## Gotchas

- Do not assume slash commands exist in every client. In Codex and other Agent Skills clients, execute the referenced workflow directly. This applies to `/opsx:*` as well: Codex gets OpenSpec Agent Skills only, so delegate to whichever `openspec-*` skills the repository actually has, and to the `openspec` CLI when it has none.
- Claude Code wrappers may expose `/devflow:*` commands, but this skill is the canonical source of behavior. The wrappers are optional; a repository configured for DevFlow works the same without them.
- `allowed-tools`, `argument-hints`, `Task`, `AskUserQuestion`, web tool names, and `${CLAUDE_PLUGIN_ROOT}` are Claude Code plugin details; do not rely on them in portable workflows.
- Network access, GitHub authentication, and local dependency installation vary by client. Verify availability before depending on them.
