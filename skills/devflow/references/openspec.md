# OpenSpec / OPSX Integration

Use this when a repository has OpenSpec configured and a DevFlow workflow needs to create, continue, validate, or archive planning artifacts. OpenSpec is always optional in DevFlow.

## Compatibility

| Item | Value |
|---|---|
| npm package | `@fission-ai/openspec` |
| Supported range | `>=1.0.0 <2.0.0` |
| Verified against | `1.14.1` (published 2026-10-06) |
| Node.js | `>=20.19.0` |
| Repository marker | `openspec/config.yaml` |

The bare `openspec` name on npm is an unrelated abandoned package stuck at `0.0.0`. Never recommend `npm install -g openspec`.

## Assumptions

1. **The `openspec` CLI is installed globally** and available on `PATH`, via `npm install -g @fission-ai/openspec@latest`. DevFlow never installs it. Confirm with `openspec --version` (or `openspec version --json` for a parseable answer), and if the version falls outside the supported range, run `openspec --help` and adapt rather than trusting this document.
2. **The repository has been initialized** with `openspec init --tools <clients>`, so the generated skills are committed in-repo.
3. **DevFlow delegates to OpenSpec Skills**, never to slash commands. Skills carry the same names on Claude Code and Codex, so they are the only portable handle.
4. **`/opsx:*` slash commands are optional and Claude Code only.** A user may install them for their own use in other projects; that is their choice and DevFlow must not depend on it, require it, or ask them to change their profile.

## Why Skills, Not Slash Commands

`openspec init` generates a different surface per client. On 1.14.1 with `--tools claude,codex`:

| Client | Slash commands | Agent Skills |
|---|---|---|
| Claude Code | `.claude/commands/opsx/` | `.claude/skills/openspec-*` |
| Codex | none | `.agents/skills/openspec-*` |

Codex gets no slash commands at all, and the two surfaces use different names (`/opsx:apply` versus `openspec-apply-change`). Skills are generated identically for every configured client, so delegating to a skill is the one approach that works everywhere.

Since 1.7, Codex writes to the vendor-neutral `.agents/skills/` tree instead of `.codex/skills/`. That tree is shared with other tools (`agents`, Amp, Antigravity, Zed), and OpenSpec records which one owns it in `.agents/skills/.openspec-target`. A repository initialized before 1.7 may still carry a legacy `.codex/skills/` copy; the discovery glob below matches both locations.

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
- **The profile that decides which skills are generated is per-machine.** `openspec config` writes to a global XDG-based config file, and `--scope` accepts only `global` on 1.14.1. The generated skills themselves are written into the repository and committed, but the profile that produced them belongs to whoever ran `openspec init` or `openspec update`. So two contributors on the same repository can commit different `openspec-*` sets, and the set already committed may not match what your own profile would generate.

Because of this, a DevFlow step must never hardcode a skill name as its primary path. Resolve the skill at run time instead:

1. **List what is actually present.** OpenSpec writes each skill to `<client-dir>/skills/openspec-<workflow>/SKILL.md`, where the client directory is `.claude` for Claude Code, `.agents` for Codex and the other tools that share it, `.cursor` for Cursor, and so on. Listing them is one command in any client, run from the repository root; `[!.]` keeps `..` out of the match, which a plain `.*` includes in some shells:

   ```bash
   ls -d ./.[!.]*/skills/openspec-* 2>/dev/null
   ```

2. **Match by purpose, not by name.** Use the table above to map the purpose you need onto one of the names you just listed. Purpose is the stable handle; the name is only stable within a profile.
3. **Fall back to the CLI** when nothing matches. It is the only always-available surface.

Delegating means reading the resolved `SKILL.md` and following it. The file does not have to sit in your own client's directory: when the listing finds the same skill in several directories, prefer your client's copy, but a match found only in another client's tree, such as `.agents/skills/` seen from Claude Code, is still a valid delegation target.

State which skill you resolved to, or that you fell back to the CLI, so the user can see which path ran. Resolve every delegation this way, not just the first one in a workflow: a profile that installs `propose` may still omit `apply` or `archive`.

## CLI Fallback And Gates

Every generated skill drives the same CLI, so the CLI reaches every artifact and state transition the skills produce. It does not reproduce their prompting: a skill body also carries stance and procedure that shape how the agent works, most visibly in `openspec-explore`. Treat the CLI as a complete fallback for outcomes, not as an equivalent of the skill. Use it directly in two cases:

- **Deterministic gates.** A validation entry in `.devflow/check.md` must be a shell command, so use [the validation gate](#the-validation-gate), which wraps `openspec validate <change> --type change --strict`.
- **No skills available.** If the listing finds nothing, drive the CLI yourself. That happens when the repository was never initialized, or when the user's global `delivery` setting is `commands`, which suppresses skills for every tool that has slash commands. Skills-only tools such as Codex still get skills under `commands`, so another client's tree may still be listed; see the delegation note above.

```bash
openspec --version                          # confirm compatibility first
openspec list                               # active changes (--specs for specs, --archived for archived)
openspec status --change <name> --json      # artifact state, including applyRequires
openspec status --all --json                # every active change in one call
openspec show <name> --diff                 # what the change's deltas alter in the main specs
openspec instructions <artifact> --change <name> --json   # template, rules, output path
openspec instructions apply --change <name> --json        # task list and context files
openspec validate <name> --type change --strict   # pre-PR gate; the target is mandatory
openspec archive <name> --yes               # non-interactive: confirms spec updates and unchecked tasks
```

For the fallback flow: `openspec new change <name>` scaffolds the change, `status --json` reports which artifacts `applyRequires`, and `instructions <artifact> --json` returns the `template` to write, the `dependencies` to read first, and the `resolvedOutputPath` to write to. Loop until every required artifact is `done`. The `context` and `rules` fields constrain what you write; never copy them into the artifact.

Notes:

- **`openspec validate` always needs an explicit target.** The item name is optional in the CLI signature, and with no name and no `--all` / `--changes` / `--specs` the command never validates anything: non-interactively it prints a hint and exits `1`, interactively it opens a picker and waits. Neither is usable as a gate — one fails on every run regardless of the specs, the other blocks. Always pass a change name, or `--changes` / `--specs` / `--all` when the gate is not tied to a single change.
- There is **no** `openspec workflow` command in any 1.x release.
- `openspec change list` is deprecated in favor of `openspec list`.
- The default `spec-driven` schema uses `proposal → specs → design → tasks`. Other schemas exist, so read the artifact list from `status` instead of hardcoding names.
- **A change that owns no spec behavior declares it.** Pure refactors, tooling, and documentation changes set `skip_specs: true` in the change's `.openspec.yaml` while planning. Without it, `openspec validate <change>` fails with `Change must have at least one delta`, and with it the change validates and archives with no further flag; `status` then reports the `specs` artifact as `skipped`. The declaration may be added at any point before archiving. DevFlow never uses `openspec archive --skip-specs`, which skips the merge only at the last step and leaves the validate gate failing until then.
- **`--strict` covers more than the change's deltas.** It also fails on a requirement longer than 500 characters, unrecognized keys in `.openspec.yaml`, and task-numbering problems in `tasks.md`. Over the main specs, it fails on a placeholder `## Purpose`, which is exactly what `openspec archive` writes when a new capability's delta carries no `## Purpose` of its own. Write that section in the delta when a change creates a capability, or replace the placeholder in the main spec after archiving.
- **`openspec validate --archived` conflicts with post-merge tasks.** It fails on any archived change with an unchecked task, and DevFlow deliberately archives with post-merge tasks unchecked. Do not add it as a gate in a repository that follows the post-merge rule below.

## The Validation Gate

`openspec validate <change> --type change --strict` is the pre-PR gate; `--type change` keeps a capability spec of the same name from making the target ambiguous. In `.devflow/check.md` it is the `opsx_validate` entry, which runs `sh .devflow/scripts/opsx-validate.sh`; setup copies that script into the repository from [assets/scripts/opsx-validate.sh](../assets/scripts/opsx-validate.sh). An `opsx_validate` entry with `enabled: false` is skipped like any disabled check. Only when `check.md` has no `opsx_validate` entry at all, or there is no `check.md`, apply the same rules yourself. An enabled `opsx_validate` that appears only in a later JSON block counts as absent here (a disabled one stays skipped), because [check.md](check.md#configuration-format) never runs later blocks. Configurations written before DevFlow 2.3.0 carry the gate as one inline command instead. Recognize it by its text, not by version. This applies only to entries that validate; `opsx_status`, which only displays a change's status, is current and stays inline:

- An inline command that resolves the name with `openspec list --json` and runs `openspec validate --all --strict` when no change matches is the 2.2.2 gate. It behaves like the script did before 2.4.1: once the branch's change is archived it validates `--all`, so another person's active change can fail it, and it omits `--type change`. Report its result normally and recommend re-running setup to replace it with the script.
- Any other entry that runs `openspec validate`, or the old `opsx_verify` entry, is an outdated gate: earlier versions shipped commands that pass without validating the change, call a target-less `openspec validate`, or run commands that no longer exist. Report its result with a warning that the gate is outdated, and recommend re-running setup to replace it with the script.

The gate picks its target as follows:

1. **Name.** `DEVFLOW_OPENSPEC_CHANGE` when it is set, otherwise the last path segment of the current branch. Either way the name is lowercased, because change names are lowercase kebab-case and `openspec validate` matches them exactly. The development workflow names changes so that the branch supplies the name.
2. **Active change.** When the name is among the changes `openspec list --json` reports, validate that change with `--type change --strict`. Resolve through the CLI, never by testing `openspec/changes/<name>` on disk, which misses store-backed changes. Extract the names from the JSON rather than matching its line layout, and do not decide by the `openspec status` exit code, which also fails for a change whose metadata is broken.
3. **Archived change.** When the name matches an archived change, either as `<name>` or as the `YYYY-MM-DD-<name>` id that `openspec list --archived` prints, its deltas already live in the main specs, so the gate runs `openspec validate --specs --strict` and says so on stderr. Other people's active changes therefore cannot fail a branch whose own change is archived. This holds for a branch-derived name and for `DEVFLOW_OPENSPEC_CHANGE` alike.
4. **Nothing matches.** A branch-derived name that matches no active or archived change covers the default branch, a detached CI checkout, a branch for unrelated work, and a mistyped name. The gate then runs `openspec validate --all --strict`, which checks the main specs and every active change, so it never passes without checking the branch's change. It says so on stderr. `DEVFLOW_OPENSPEC_CHANGE` is strict: when it matches nothing, the gate exits `2`.

Report each exit code differently:

| Exit | Meaning | Report |
|---|---|---|
| `0` | Validation passed | `pass`; after a `--specs` or `--all` run, note that no single change was targeted |
| `1` | Validation failed | `fail`, like any other validation failure |
| `2` | Broken configuration: missing CLI, `openspec list` failing, or a `DEVFLOW_OPENSPEC_CHANGE` that names no active or archived change | broken configuration, never a validation failure |
| `127` | The shell found no command: `.devflow/scripts/opsx-validate.sh` is missing, or an outdated inline gate could not find the `openspec` CLI. Some shells, such as dash, exit `2` for a missing script instead, so after a `2` check that the file exists | broken configuration; re-run setup to copy the script, or install the CLI |

A gate that runs `openspec validate` with no target validates nothing (see the first note above), and it exits `1` like a real failure. Inspect a hand-written gate's command before running it: when it calls `openspec validate` without a change name, `--changes`, `--specs`, or `--all`, report it as broken configuration without running it, never as a validation failure.

## Use Within DevFlow Workflows

Every delegation below names a skill by its usual `core` name for readability. Resolve it through the discovery steps above before using it, and fall back to the CLI when it is absent.

- **Feature planning**: OpenSpec is not required. If the user wants specs before code, delegate to the skill that creates a change (`openspec-propose`) once the user approves the draft; the GitHub issue stays the source of truth for scope. The change stays uncommitted until the development workflow carries it onto its branch.
- **Implementation**: prepare the branch first, then create or continue the change's artifacts in its checkout, so they land on the branch, and delegate to the skill that implements a change's tasks (`openspec-apply-change`). The change name equals the branch's last path segment: an existing change gives `feat/<change-name>`, and a new one takes the lowercased last segment of the branch the development workflow chooses: the user's branch, the configured convention, or `issue-<number>-<slug>` from the default `feat/issue-<number>-<slug>`. [The validation gate](#the-validation-gate) derives the change from the branch this way, and reads `DEVFLOW_OPENSPEC_CHANGE` instead for a branch that cannot follow the rule.
- **Validation**: add [the validation gate](#the-validation-gate) only when the repository has OpenSpec configured, and report it alongside tests, lint, typecheck, and build.
- **Before the PR**: delegate to the skill that finalizes a change (`openspec-archive-change`) so the main specs reflect merged behavior, and reference the change name in the PR body. Archiving must include spec synchronization: when the skill offers to archive without syncing, choose to sync. `openspec archive` merges the delta specs by default; a change that owns no specs declares `skip_specs: true` instead, and DevFlow never uses `--skip-specs`. After archiving, run `openspec validate --specs --strict` to catch a placeholder `## Purpose` on a newly created capability; report failures in specs the change did not touch rather than fixing them. Then commit the resulting spec updates on the branch so the PR carries them.
- **Post-merge work**: tasks that can only run after the merge, such as deployment and production verification, are not part of implementation and must not hold up archiving. Record them in the PR body instead. Archiving does block on unchecked tasks, so confirm the only ones left are post-merge items and then acknowledge the warning. Non-interactively that means `openspec archive <name> --yes`, which confirms both the spec updates and the unchecked tasks; without it the command fails and names the flag it needs. Never tick a post-merge task to unblock the archive.

## Store-Backed Repositories

OpenSpec 1.5 added stores (beta): standalone OpenSpec repositories registered per machine. A store-only project still has `openspec/config.yaml`, so DevFlow treats OpenSpec as configured, but the file holds only a `store: <id>` line and every change and main spec lives in the store's repository, not in this one. Detect it with `openspec list --json`: a `root` object carrying `store_id` means the planning artifacts are elsewhere.

The workflows above change in three places for such a repository:

- `openspec archive` updates the main specs in the store, so the code PR carries no spec diff. The store repository needs its own commit and push, and the PR body should name the store and the change.
- A review must not report the missing spec diff as a finding. Confirm the change shows as archived with `openspec list --archived` instead.
- A gate that tests `openspec/changes/<name>` on disk never sees the change, which is why [the validation gate](#the-validation-gate) resolves changes through the CLI.

Only `openspec/config.yaml` marks a repository as using OpenSpec. A machine-wide `defaultStore` makes `openspec list` resolve a store from any directory, including repositories that never adopted OpenSpec, so never infer adoption from a successful CLI call.
