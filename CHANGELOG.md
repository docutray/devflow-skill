# Changelog

All notable changes to this project are documented in this file.

This project follows Semantic Versioning.

## [Unreleased]

## [2.1.1] - 2026-07-30

### Fixed
- `dev.md` step 4 could name only skills that do not exist. It hardcoded `openspec-propose`
  and `openspec-update-change` as guaranteed and warned that `openspec-continue-change` might
  be missing, but OpenSpec's `custom` profile selects an arbitrary subset of workflows, so the
  documented ordering can be exactly inverted and every named path can fail. The step now says
  to list what is present with `ls -d .*/skills/openspec-* 2>/dev/null`, match one by purpose,
  and otherwise use the CLI fallback. The listing is reused for the apply and archive
  delegations in `dev.md`, since a profile that installs `propose` can still omit those.
- The documented pre-PR gate never validated anything. `check.md` and `openspec.md` described it
  as bare `openspec validate --strict`, but the item name is optional in the CLI signature, and
  with no name and no bulk flag the command validates nothing: non-interactively it prints a hint
  and exits `1`, interactively it opens a picker and waits. Both now require an explicit target,
  `openspec validate <change> --strict`, with `--changes` / `--all` for gates not tied to a
  single change. The check templates were already correct.

### Added
- `openspec.md` documents why no `openspec-*` skill is guaranteed: `custom` is a first-class
  profile selecting an arbitrary subset of workflows, and the profile that decides what gets
  generated is per-machine, since `openspec config` writes to a global XDG-based file and
  `--scope` accepts only `global`. The skills themselves are committed in-repo, but the set
  reflects whoever ran `openspec init`, so two contributors can commit different ones.

### Changed
- `openspec.md` no longer presents the CLI fallback as equivalent to a skill. It reaches every
  artifact and state transition the skills produce, but not their prompting; `openspec-explore`
  is mostly stance rather than CLI calls.

## [2.1.0] - 2026-07-28

### Added
- `skills/devflow/references/openspec.md`: documents the supported OpenSpec version
  (`@fission-ai/openspec` 1.x, verified against 1.6.0, Node >= 20.19.0), the CLI surface
  DevFlow relies on, and the `core` vs. expanded `/opsx:*` command profiles.

### Fixed
- Resolved a contradiction in the `.devflow/` migration rules: the setup workflow said to
  update legacy files in place while `SKILL.md` said the legacy location is never written.
  The rule is now that no new file is created there, but an existing one is edited in place so
  a repository keeps a single source of truth.
- `.devflow/` holds committed configuration next to an ignored `worktrees/` subdirectory, so
  the guidance now says to ignore `.devflow/worktrees/` specifically. Ignoring `.devflow/`
  wholesale would silently drop the project's configuration.
- PR review now verifies what the development workflow produces: that post-merge tasks really
  cannot be done before merge, and that an OpenSpec change was archived with its specs synced.
- Archiving no longer contradicts the post-merge task rule. `openspec archive` blocks on
  unchecked tasks, so `dev.md` now says to confirm the only unchecked items are post-merge
  ones and acknowledge the warning, never to tick them or to bypass a genuine blocker.
- `dev.md` no longer directs work to `openspec-continue-change` unconditionally. That skill is
  outside the default OpenSpec profile, so it is used only after confirming it exists.
- Replaced `openspec workflow verify` in the Python and TypeScript check templates with
  `openspec validate <change> --strict`. No `openspec workflow` command exists in any 1.x release.
- Documented `@fission-ai/openspec` as the package name. The bare `openspec` npm package is
  unrelated and abandoned at `0.0.0`.

### Changed
- **Project-local configuration moved to a client-neutral `.devflow/` directory.** Writing
  `.claude/` into a repository contradicted treating Codex as a first-class client. The legacy
  `.claude/details/commands/` location is still read for backward compatibility and is never
  written; existing repositories keep working and are not migrated automatically. Worktrees
  follow the same rule, preferring `.devflow/worktrees/`.
- DevFlow is now skill-first, with Codex and Claude Code as equally supported clients. The
  skill is the interface and is driven in natural language; `/devflow:*` slash commands are
  documented as optional Claude Code shortcuts that add no behavior.
- Added a `Workflow Handoffs` table to `SKILL.md`. Every workflow now recommends the next one
  by workflow name rather than by slash command, so the guidance works in any client.
- Reframed the README, framework templates, and worktree guide around workflow names instead
  of command names.
- OpenSpec integration is now client-agnostic and delegates to the `openspec-*` Agent Skills,
  which carry identical names on Claude Code and Codex. `/opsx:*` slash commands are Claude Code
  only and are treated as an optional user preference DevFlow never depends on. The `openspec`
  CLI remains the fallback and the way to express shell validation gates.
- DevFlow now states its OpenSpec assumptions explicitly: the CLI is installed globally, the
  repository was initialized with `openspec init --tools <clients>`, and the user's workflow
  profile and delivery settings are left untouched.
- OpenSpec detection now keys strictly on `openspec/config.yaml`.
- `dev.md` now requires OpenSpec whenever `openspec/config.yaml` is present, rather than
  treating it as optional once configured.
- `dev.md` makes archiving with spec synchronization an explicit pre-PR step. `--skip-specs`
  is reserved for tooling and documentation changes.
- `dev.md` excludes post-merge work (deployment, production verification, monitoring,
  rollout, post-release sign-off) from implementation. Those tasks are recorded in a new
  `## Post-Merge Tasks` section of the PR body and must not block archiving.

## [2.0.1] - 2026-05-07

### Added
- Canonical DevFlow setup workflow reference for `/devflow:devflow-setup`.

### Changed
- Improved DevFlow validation inference for Node/TypeScript projects by detecting package managers from lockfiles and preferring existing project scripts.
- Softened framework templates so recommended defaults defer to each repository's existing conventions.

## [2.0.0] - 2026-04-30

### Changed
- **BREAKING packaging change**: DevFlow is now an Agent Skill first, with the canonical implementation in `skills/devflow/SKILL.md`.
- Claude Code slash commands are now compatibility wrappers that delegate to the portable skill references.
- Marketplace metadata now installs the `devflow` skill from `./skills/devflow`.

### Added
- `npx skills add https://github.com/docutray/devflow-skill --skill devflow` installation path.
- Portable DevFlow references for feature planning, implementation, validation, PR review, research, and epic planning.
- Skill assets copied from the existing DevFlow templates.

### Removed
- **rag-research** plugin: removed from the marketplace. The RAG document indexing
  and semantic search plugin (Qdrant + FastEmbed) has been deprecated from this
  repository. The marketplace now focuses exclusively on `devflow`.

## [1.2.0] - 2025-01-26

### Changed (devflow)
- **BREAKING**: Migrated from legacy OpenSpec commands to OPSX (fluid workflow)
- `/dev` command now uses OPSX slash commands:
  - `/opsx:new` or `/opsx:ff` to create planning artifacts from GitHub issue
  - `/opsx:apply <change>` to guide implementation following tasks
  - `/opsx:verify <change>` to validate implementation against specs
  - `/opsx:sync <change>` to preview spec merge
  - `/opsx:archive <change>` to finalize change before creating PR
- Updated OPSX detection: now checks for `openspec/config.yaml` (primary) or legacy directories
- Added support for discrete artifact workflow (proposal -> specs -> design -> tasks)
- `/devflow-setup` now includes full OPSX setup instructions:
  - `npm install -g openspec`
  - `openspec init` + `openspec experimental`
  - Lists all available OPSX commands
- `/check` updated with new OPSX validation commands (`openspec status`, `openspec workflow verify`)

### Added (devflow)
- Three OPSX workflow options in `/dev`:
  - Fast-forward (`/opsx:ff`) for well-defined issues
  - Incremental (`/opsx:new` + `/opsx:continue`) for exploratory work
  - Exploration first (`/opsx:explore`) for brainstorming
- Verification step (`/opsx:verify`) before archiving in `/dev` workflow

## [1.1.5] - 2025-12-31

### Changed (devflow)
- `/dev` command now uses OpenSpec slash commands instead of CLI commands:
  - `/openspec:proposal issue#<number>` to generate proposal from GitHub issue
  - `/openspec:apply <change>` to guide implementation following the spec
  - `/openspec:archive <change>` to archive specs before creating PR
- Updated implementation flow documentation to reflect new OpenSpec integration

## [1.1.4] - 2025-12-30

### Added
- **rag-research** plugin (v1.1.1): RAG-based reference document management
  - Semantic search across indexed documents (PDF, Markdown, Text)
  - Uses Qdrant + FastEmbed for local vector storage
  - Project-local database support
  - Commands: `/rag-research:add-doc`, `/rag-research:research`, `/rag-research:list`

## [1.1.1] - 2025-12-26

### Fixed
- Fix marketplace source path to use `./` prefix (required by schema)

## [1.1.0] - 2025-12-26

### Changed
- **BREAKING**: Reorganized repository to marketplace structure for multiple plugins
- Moved devflow plugin to `plugins/devflow/` directory
- Plugin installation used the marketplace name available at that release.
- Moved `README-devflow.md` to `plugins/devflow/README.md`
- Updated root `README.md` as marketplace documentation
- Updated `CLAUDE.md` with new structure guidelines

### Added
- `marketplace.json` with `pluginRoot` configuration for cleaner plugin paths
- Support for multiple plugins in single repository
- Documentation for adding new plugins to the marketplace

### Removed
- Root-level `plugin.json` (now in each plugin's `.claude-plugin/` directory)
- Root-level `commands/` and `templates/` (now under `plugins/devflow/`)

## [1.0.1] - 2025-12-26

### Added
- OpenSpec integration guidance in the DevFlow docs.
- Optional OpenSpec validations (validate/archive) examples in the `/check` configuration templates.

### Changed
- `/dev` now describes generating an OpenSpec change proposal at dev start (when `openspec/` is present) and archiving the change before opening a PR.
- `/check` now documents how to wire OpenSpec validation/archive into project-specific `.claude/details/commands/check.md`.
- `/devflow-setup` now includes optional steps to install and initialize OpenSpec (`openspec init`, `openspec update`).

## [1.0.0] - 2025-12-XX

### Added
- Initial DevFlow command set: `/feat`, `/dev`, `/check`, `/review-pr`, `/research`, `/epic`, `/devflow-setup`.
