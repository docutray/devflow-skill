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

## Detection

Treat OpenSpec as configured only when `openspec/config.yaml` exists. Do not infer it from a stray `openspec/` directory alone, and do not run `openspec init` unless the user explicitly asks to enable OpenSpec.

`openspec/config.yaml` declares the workflow schema (`schema: spec-driven` by default) and may carry project `context:` and per-artifact `rules:`. Read it before generating artifacts; it tells you which artifacts a change requires.

## CLI Commands DevFlow Relies On

```bash
openspec --version                          # confirm compatibility first
openspec list                               # active changes (openspec list --specs for specs)
openspec status --change <name> [--json]    # artifact completion for one change
openspec validate <name> [--strict] [--json]
openspec validate --changes --strict        # validate every active change
openspec archive <name> [-y] [--skip-specs]
openspec instructions <artifact> --change <name> --json
openspec new change <name>
openspec init [--tools claude,codex] [--profile core|custom]
openspec update                             # refresh generated instructions and commands
openspec config profile                     # choose which workflow commands are installed
```

Notes:

- There is **no** `openspec workflow` command in any 1.x release. Use `openspec validate --strict` as the pre-PR gate and `openspec status --change` for progress.
- `openspec change list` is deprecated in favor of `openspec list`.
- `--json` is available on most read commands and is the right choice for scripted checks.

## Slash Commands

`openspec init` generates both slash commands and Agent Skills, so OPSX workflows are reachable from Claude Code and from Agent Skills clients such as Codex.

Default `core` profile — six commands:

| Command | Purpose |
|---|---|
| `/opsx:propose <idea>` | Create a change and generate all artifacts needed to implement |
| `/opsx:explore` | Explore options before committing to a plan |
| `/opsx:apply [change]` | Implement the change's tasks |
| `/opsx:sync [change]` | Preview merging the change back into the main specs |
| `/opsx:archive [change]` | Finalize a completed change |
| `/opsx:update [change]` | Revise artifacts on an existing change |

Six more exist but are installed only when the user selects them via `openspec config profile`: `/opsx:new`, `/opsx:continue`, `/opsx:ff`, `/opsx:verify`, `/opsx:bulk-archive`, `/opsx:onboard`.

Never assume the expanded set is present. Check `.claude/commands/opsx/` (or the client's equivalent) and fall back to the CLI, which always works regardless of profile.

## Use Within DevFlow Workflows

- **Feature planning**: OpenSpec is not required. If the user wants specs before code, `/opsx:propose` replaces ad-hoc planning notes; the GitHub issue stays the source of truth for scope.
- **Implementation**: after selecting the branch, create or continue the change, then implement its tasks. The change name usually matches the branch slug.
- **Validation**: add `openspec validate --strict` as an extra gate only when the repository has OpenSpec configured. Report it alongside tests, lint, typecheck, and build.
- **Before the PR**: archive the completed change so the main specs reflect merged behavior, and reference the change name in the PR body.
