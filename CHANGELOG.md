# Changelog

All notable changes to this project are documented in this file.

This project follows Semantic Versioning.

## [Unreleased]

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
