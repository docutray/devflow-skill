# OpenSpec / OPSX Integration

Use this when a repository has OpenSpec configured and a DevFlow workflow needs to create, continue, validate, or archive planning artifacts. OpenSpec is always optional in DevFlow.

## Compatibility

| Item | Value |
|---|---|
| npm package | `@fission-ai/openspec` |
| Supported range | `>=1.0.0 <2.0.0` |
| Verified against | `1.6.0` (published 2026-07-10) |
| Node.js | `>=20.19.0` |
| Repository marker | `openspec/config.yaml` |

Install with `npm install -g @fission-ai/openspec@latest`.

The bare `openspec` name on npm is an unrelated abandoned package stuck at `0.0.0`. Never recommend `npm install -g openspec`.

Before relying on any command below, confirm the installed version with `openspec --version`. If it falls outside the supported range, run `openspec --help` and adapt rather than assuming this document is still accurate.

## The CLI Is The Contract

**Drive OpenSpec through the `openspec` CLI, never through client-specific wrappers.** The CLI is identical on every client; the wrappers are not.

`openspec init` generates a different surface per tool. With `--tools claude,codex` on 1.6.0:

| Client | Slash commands | Agent Skills |
|---|---|---|
| Claude Code | `.claude/commands/opsx/` (6) | `.claude/skills/openspec-*` (6) |
| Codex | none | `.codex/skills/openspec-*` (6) |

Names differ across the two surfaces, so no single identifier works everywhere:

| Workflow | Claude Code command | Skill name |
|---|---|---|
| Propose | `/opsx:propose` | `openspec-propose` |
| Explore | `/opsx:explore` | `openspec-explore` |
| Apply | `/opsx:apply` | `openspec-apply-change` |
| Update | `/opsx:update` | `openspec-update-change` |
| Sync | `/opsx:sync` | `openspec-sync-specs` |
| Archive | `/opsx:archive` | `openspec-archive-change` |

Every generated wrapper declares `allowed-tools: Bash(openspec:*)` and its body is a sequence of `openspec` CLI calls. Nothing is lost by calling the CLI directly.

Two consequences for DevFlow:

- Never make a `/opsx:*` command a required step, and never assume a skill name is installed. If the user invokes one, follow it; otherwise run the CLI sequence yourself.
- The workflow profile (`core` by default, or `custom` via `openspec config profile`) only controls **which wrappers get generated**. It does not change the CLI, so it does not change DevFlow's behavior. Do not ask the user to change their profile.

## Detection

Treat OpenSpec as configured only when `openspec/config.yaml` exists. Do not infer it from a stray `openspec/` directory alone, and do not run `openspec init` unless the user explicitly asks to enable OpenSpec.

`openspec/config.yaml` declares the workflow schema (`schema: spec-driven` by default) and may carry project `context:` and per-artifact `rules:`. Read it before generating artifacts; it tells you which artifacts a change requires.

## Client-Agnostic Command Sequence

```bash
openspec --version                          # confirm compatibility first
openspec list                               # active changes (--specs for specs)
openspec status --change <name> --json      # artifact state, and applyRequires
openspec instructions <artifact> --change <name> --json
openspec instructions apply --change <name> --json
openspec validate <name> --strict           # pre-PR gate
openspec archive <name> [-y] [--skip-specs]
```

**Planning.** `openspec new change <name>` scaffolds the change. `openspec status --change <name> --json` returns `applyRequires` (artifacts needed before implementation), each artifact's status and dependencies, and the resolved paths. Loop over the ready artifacts: call `openspec instructions <artifact> --change <name> --json`, which returns `template` (the structure to write), `instruction` (schema guidance), `dependencies` (completed artifacts to read first), and `resolvedOutputPath` (where to write). Write the file there, then re-run `status` until every `applyRequires` artifact is `done`.

`context` and `rules` in that JSON are constraints on what you write, not content to copy into the artifact.

**Implementation.** `openspec instructions apply --change <name> --json` returns `contextFiles` (artifact id to file paths), task list, and progress. Read the context files, implement each task, and tick `- [ ]` to `- [x]` in the tasks file as you go.

**Validation and handoff.** `openspec validate <name> --strict` is the pre-PR gate. `openspec archive <name>` merges the change into the main specs.

The default `spec-driven` schema has artifacts `proposal → specs → design → tasks`. Other schemas exist; read the artifact list from `status` rather than hardcoding those names.

Notes:

- There is **no** `openspec workflow` command in any 1.x release.
- `openspec change list` is deprecated in favor of `openspec list`.
- `--json` is available on most read commands and is the right choice for scripted checks.

## Use Within DevFlow Workflows

- **Feature planning**: OpenSpec is not required. If the user wants specs before code, use the planning sequence above; the GitHub issue stays the source of truth for scope.
- **Implementation**: after selecting the branch, create or continue the change, then implement its tasks. The change name usually matches the branch slug.
- **Validation**: add `openspec validate --strict` as an extra gate only when the repository has OpenSpec configured. Report it alongside tests, lint, typecheck, and build.
- **Before the PR**: archive the completed change so the main specs reflect merged behavior, and reference the change name in the PR body.
