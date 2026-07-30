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

The bare `openspec` name on npm is an unrelated abandoned package stuck at `0.0.0`. Never recommend `npm install -g openspec`.

## Assumptions

1. **The `openspec` CLI is installed globally** and available on `PATH`, via `npm install -g @fission-ai/openspec@latest`. DevFlow never installs it. Confirm with `openspec --version`, and if the version falls outside the supported range, run `openspec --help` and adapt rather than trusting this document.
2. **The repository has been initialized** with `openspec init --tools <clients>`, so the generated skills are committed in-repo.
3. **DevFlow delegates to OpenSpec Skills**, never to slash commands. Skills carry the same names on Claude Code and Codex, so they are the only portable handle.
4. **`/opsx:*` slash commands are optional and Claude Code only.** A user may install them for their own use in other projects; that is their choice and DevFlow must not depend on it, require it, or ask them to change their profile.

## Why Skills, Not Slash Commands

`openspec init` generates a different surface per client. On 1.6.0 with `--tools claude,codex`:

| Client | Slash commands | Agent Skills |
|---|---|---|
| Claude Code | `.claude/commands/opsx/` | `.claude/skills/openspec-*` |
| Codex | none | `.codex/skills/openspec-*` |

Codex gets no slash commands at all, and the two surfaces use different names (`/opsx:apply` versus `openspec-apply-change`). Skills are generated identically for every configured client, so delegating to a skill is the one approach that works everywhere.

Delegating also keeps DevFlow thin: each skill already encodes OpenSpec's current procedure and guardrails, and `openspec update` refreshes it. DevFlow does not need to restate that flow or track its changes.

## Skills DevFlow Delegates To

The `core` preset installs the first six. The rest exist only if the user selected them via `openspec config profile`.

| Purpose | Skill | In `core` |
|---|---|---|
| Create a change with all artifacts | `openspec-propose` | yes |
| Explore options before planning | `openspec-explore` | yes |
| Implement the change's tasks | `openspec-apply-change` | yes |
| Revise artifacts on a change | `openspec-update-change` | yes |
| Merge delta specs into main specs without archiving | `openspec-sync-specs` | yes |
| Finalize a completed change | `openspec-archive-change` | yes |
| Scaffold an empty change | `openspec-new-change` | no |
| Resume a partially planned change | `openspec-continue-change` | no |
| Plan and implement in one pass | `openspec-ff-change` | no |
| Verify implementation against specs | `openspec-verify-change` | no |
| Archive several changes at once | `openspec-bulk-archive-change` | no |
| Guided introduction | `openspec-onboard` | no |

## No Skill Is Guaranteed

The table above says which skills the `core` preset installs, not which ones exist here. **Never treat any `openspec-*` skill as guaranteed, including the six in `core`.** Two facts make this a normal case rather than an edge case:

- `custom` is a first-class profile value. `openspec config profile` accepts it, and it selects an arbitrary subset of the workflows — possibly one that omits `propose`, `update`, or both.
- **The profile that decides which skills are generated is per-machine.** `openspec config` writes to a global XDG-based config file, and `--scope` accepts only `global` on 1.6.0. The generated skills themselves are written into the repository and committed, but the profile that produced them belongs to whoever ran `openspec init` or `openspec update`. So two contributors on the same repository can commit different `openspec-*` sets, and the set already committed may not match what your own profile would generate.

Because of this, a DevFlow step must never hardcode a skill name as its primary path. Resolve the skill at run time instead:

1. **List what is actually present.** OpenSpec writes each skill to `<client-dir>/skills/openspec-<workflow>/SKILL.md`, where the client directory is `.claude` for Claude Code, `.codex` for Codex, `.cursor` for Cursor, and so on. Listing them is one command in any client:

   ```bash
   ls -d .*/skills/openspec-* 2>/dev/null
   ```

2. **Match by purpose, not by name.** Use the table above to map the purpose you need onto one of the names you just listed. Purpose is the stable handle; the name is only stable within a profile.
3. **Fall back to the CLI** when nothing matches. It is the only always-available surface.

State which skill you resolved to, or that you fell back to the CLI, so the user can see which path ran. Resolve every delegation this way, not just the first one in a workflow: a profile that installs `propose` may still omit `apply` or `archive`.

## CLI Fallback And Gates

Every generated skill drives the same CLI, so the CLI reaches every artifact and state transition the skills produce. It does not reproduce their prompting: a skill body also carries stance and procedure that shape how the agent works, most visibly in `openspec-explore`. Treat the CLI as a complete fallback for outcomes, not as an equivalent of the skill. Use it directly in two cases:

- **Deterministic gates.** A validation entry in `.devflow/check.md` must be a shell command, so use `openspec validate <change> --strict`.
- **No skills available.** If the repository was never initialized for the current client, or the user's global `delivery` setting is `commands` (which suppresses skill generation), drive the CLI yourself.

```bash
openspec --version                          # confirm compatibility first
openspec list                               # active changes (--specs for specs)
openspec status --change <name> --json      # artifact state, including applyRequires
openspec instructions <artifact> --change <name> --json   # template, rules, output path
openspec instructions apply --change <name> --json        # task list and context files
openspec validate <name> --strict           # pre-PR gate; the target is mandatory
openspec archive <name> [-y] [--skip-specs]
```

For the fallback flow: `openspec new change <name>` scaffolds the change, `status --json` reports which artifacts `applyRequires`, and `instructions <artifact> --json` returns the `template` to write, the `dependencies` to read first, and the `resolvedOutputPath` to write to. Loop until every required artifact is `done`. The `context` and `rules` fields constrain what you write; never copy them into the artifact.

Notes:

- **`openspec validate` always needs an explicit target.** The item name is optional in the CLI signature, and with no name and no `--all` / `--changes` / `--specs` the command never validates anything: non-interactively it prints a hint and exits `1`, interactively it opens a picker and waits. Neither is usable as a gate — one fails on every run regardless of the specs, the other blocks. Always pass a change name, or `--changes` / `--specs` / `--all` when the gate is not tied to a single change.
- There is **no** `openspec workflow` command in any 1.x release.
- `openspec change list` is deprecated in favor of `openspec list`.
- The default `spec-driven` schema uses `proposal → specs → design → tasks`. Other schemas exist, so read the artifact list from `status` instead of hardcoding names.

## Use Within DevFlow Workflows

Every delegation below names a skill by its usual `core` name for readability. Resolve it through the discovery steps above before using it, and fall back to the CLI when it is absent.

- **Feature planning**: OpenSpec is not required. If the user wants specs before code, delegate to the skill that creates a change (`openspec-propose`); the GitHub issue stays the source of truth for scope.
- **Implementation**: after selecting the branch, delegate to the skill that implements a change's tasks (`openspec-apply-change`). The change name usually matches the branch slug.
- **Validation**: add `openspec validate <change> --strict` as an extra gate only when the repository has OpenSpec configured. Pass the change name explicitly, or `--changes` when the gate covers every active change. Report it alongside tests, lint, typecheck, and build.
- **Before the PR**: delegate to the skill that finalizes a change (`openspec-archive-change`) so the main specs reflect merged behavior, and reference the change name in the PR body. Archiving must include spec synchronization; `openspec archive` merges the delta specs by default, so reserve `--skip-specs` for tooling or documentation changes that own no specs. Commit the resulting spec updates on the branch so the PR carries them.
- **Post-merge work**: tasks that can only run after the merge, such as deployment and production verification, are not part of implementation and must not hold up archiving. Record them in the PR body instead. Archiving does block on unchecked tasks, so confirm the only ones left are post-merge items and then acknowledge the warning. Non-interactively that means `openspec archive <name> -y`. Never tick a post-merge task to unblock the archive.
