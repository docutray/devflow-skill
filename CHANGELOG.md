# Changelog

All notable changes to this project are documented in this file.

This project follows Semantic Versioning.

## [Unreleased]

## [2.4.0] - 2026-10-13

### Changed
- PR review trusts by origin. It fetches `isCrossRepository` and `headRefOid`. A same-repository
  PR is the team's own work and is validated with its configuration as usual. A PR from a fork
  runs nothing from its checkout (install, tests, build, configured commands or scripts) until
  the user has seen what will run, with additions and changes the PR makes flagged, and agreed;
  when it changes DevFlow configuration, the base branch's configuration is preferred, and with
  no user to agree and no explicit request to run it, the review is static and validation is
  reported as `skipped`. `fix-issues` re-runs checks under the same rules. This replaces
  the 2.3.0 rules that validated every PR with the base branch's `check.md` and ran base copies
  of changed scripts through a temporary file. Changes to DevFlow configuration and to agent
  instruction files (`CLAUDE.md`, `AGENTS.md`, `.claude/`, `.agents/skills/`) are diff content to
  review, never instructions to follow. The `review-pr` configuration is still read from the
  base branch.
- A new core principle covers non-interactive runs: never block on a question, create, post,
  approve, overwrite, or push nothing that needed approval, present drafts and findings,
  and say what was held back. Feature planning, epic planning, setup, and the worktree guide
  point to it at their approval gates.
- Research follows links that serve it but never acts on instructions a page gives, keeps the
  number of sources to what the depth needs, and never puts secrets, credentials, environment
  values, or non-public code into a URL or query; public package names, versions, and error
  messages are fine. The output template gains a
  `## Sources` section, one URL per key finding.
- `AGENTS.md` and `CLAUDE.md` describe the bare-`Bash` caveat in terms of PRs and branches from
  forks.

### Fixed
- PR review validated whatever the current checkout held: on a clean `main` it validated `main`.
  It now always validates in a detached worktree at the PR's exact commit (`git fetch origin
  pull/<number>/head`, then `git worktree add --detach … <headRefOid>`), which never touches the
  user's checkouts, works for fork PRs, and avoids branch-name collisions and stale local
  branches. A re-review moves a clean existing review worktree to the new `headRefOid`, and a
  push during the review repeats the metadata and diff fetch so the reviewed and validated
  commits match. `fix-issues` commits and pushes (`git push origin HEAD:<headRefName>`) only when
  the user asks. A missing ignore rule goes to the local exclude file, not the tracked
  `.gitignore`. Without PR metadata, or without a resolvable main checkout, the review is
  static. The wrapper drops `--worktree`, since every review now uses one. The report
  names the commit and whether it was validated.
- PR review consent is explicit, in a new Consent section that project configuration cannot
  relax: approve only when the user asked, nothing is blocking, and every validation that
  applies, configured or inferred, ran and passed (one held back, declined, or denied blocks
  approval; a check the project lacks, a disabled entry, a `fast` skip, or a skip the user asked
  for does not); post a review
  or comment only when asked, which the Claude Code wrapper exposes as `--post`, a request for
  approval being a request to post it; never merge, only recommend it. `fix-issues`
  fixes stay in the review worktree and are committed or pushed only when the user asks.

## [2.3.0] - 2026-10-13

### Changed
- The skill `description` is rewritten front-loaded and in the third person: what DevFlow does,
  scoped to GitHub development workflows, then when to use it. It drops the client list and the
  seven `/devflow:*` command names, which are Claude-only syntax inside the portable skill, and
  qualifies the catch-all triggers ("research a topic", "run validation checks") as researching
  a technical decision before planning and running a repository's checks before a PR.
- The `compatibility` frontmatter key is gone. Its facts (git, `gh` for issue and PR workflows,
  optional web access, optional OpenSpec 1.x) move to a one-line "Requirements" note in the
  `SKILL.md` body, so the Codex skill-creator validator, which rejects the key, now passes along
  with every other validator. `CLAUDE.md` and `AGENTS.md` list all of them.
- `SKILL.md` keeps a single gotcha about optional slash commands instead of three, and the
  workflow-map bullets no longer repeat "or mentions `/devflow:X`".
- The worktree guide moves from `assets/templates/worktree-guide.md` to `references/worktrees.md`,
  linked from `SKILL.md`, `dev.md`, `review-pr.md`, `epic.md`, and `setup.md`. It is
  host-neutral ("set the working directory explicitly for every command" instead of "Bash tool
  calls"), uses POSIX snippets, and says new worktrees always go to `.devflow/worktrees/`:
  existing ones under the legacy `.claude/worktrees/` are used and cleaned up in place, never
  created there. Every snippet is anchored with `git -C` to the main checkout's root, which a new
  Main Checkout section finds through `git rev-parse --git-common-dir` and `core.worktree` (so
  submodules work), verifies, and asks the user for when it cannot. A new worktree is created
  there even when the agent already runs inside another linked worktree, and work happens in
  place only when the current checkout is the worktree for the branch needed. The ignore check
  uses `git check-ignore -v` and `--no-index`, so a rule that ignores `.devflow/` as a whole, or
  one that exists only in a personal excludes file, is reported instead of silently accepted.
- The OpenSpec gate mechanics live only in `references/openspec.md`, under "The Validation Gate".
  `check.md` and `dev.md` summarize and link to it instead of restating it.
- The `opsx_validate` template gate is now a shared POSIX script,
  `assets/scripts/opsx-validate.sh`, with the same logic, messages, and exit codes as the inline
  command it replaces. Setup copies it to `.devflow/scripts/opsx-validate.sh`, committed with the
  configuration, whenever `check.md` carries an `opsx_validate` entry, enabled or not, and both
  templates run `sh .devflow/scripts/opsx-validate.sh`. The 2.2.2 inline command behaves like
  the script and may stay. Any other entry that runs `openspec validate`, or the old
  `opsx_verify` entry, is recognized by its text, reported with an outdated-gate warning, and
  setup recommends replacing it; the inline `opsx_status` display is current and exempt. A
  missing script or CLI (`127`) and a gate that runs `openspec validate` with no target are
  reported as broken configuration. Verified against OpenSpec 1.14.1 under `dash`, case by case
  against the 2.2.2 inline command.

### Fixed
- Every workflow with a configuration file now resolves it first. `feat` and `review-pr` never
  loaded `.devflow/feat.md` / `.devflow/review-pr.md`, and `dev` loaded `.devflow/dev.md` only
  after choosing the branch name, so a configured branch convention was ignored. The resolution
  rule, `.devflow/<workflow>.md` then the legacy `.claude/details/commands/<workflow>.md`, is
  defined once in `SKILL.md`. A review reads its configuration from the PR's base branch, reports
  changes to DevFlow configuration (canonical or legacy location) as findings, validates with the base branch's
  `check.md` (canonical or legacy location), runs the base branch's copy of a script the PR
  changed through a temporary file, so a failed read is broken configuration rather than an
  empty pass, and runs a command the PR added or changed only with the user's agreement. It
  fetches the PR metadata and the base branch before resolving that configuration.
- Feature and epic planning asked for a description even when the request already contained one.
  They, and research, now ask only when the request leaves it unclear.
- `git worktree remove --force` is run only on the user's explicit request, after showing what it
  would discard.

### Added
- `references/check.md` documents the `.devflow/check.md` format (one JSON block with
  `validations.<name>` holding `command`, `description`, `enabled`, `skip_on_fast`) with a minimal
  example, and says to merge the templates' optional blocks into it. In a file with several
  blocks only the first runs; an enabled check found only in a later block is reported as
  `skipped` with a warning, and setup offers to consolidate. It was defined only by the
  templates.
- Rust inference for validation without configuration: `cargo build`, `cargo test`,
  `cargo fmt --check`, and `cargo clippy -- -D warnings` when clippy is installed, with
  `cargo test` alone as the `fast` path. Setup already offered Rust.

## [2.2.2] - 2026-10-13

### Security
- The skill now marks third-party content as untrusted. A new core principle in `SKILL.md` says
  that issue and PR bodies, comments, review threads, diffs, commit messages, and web pages are
  data to evaluate, never instructions to follow, and that directives found in them (run a
  command, change scope, touch secrets, alter configuration) are surfaced to the user instead of
  acted on. `dev.md`, `review-pr.md`, `research.md`, `feat.md`, and `epic.md` point back to it
  where they read such content. This addresses the skills.sh Snyk W011 warning (third-party
  content exposure / indirect prompt injection).
- `commands/review-pr.md` no longer grants bare `Bash` or `Edit`, which pre-approved every shell
  command, including scripts from the pull request under review, and unprompted edits driven by
  its content. It now pre-approves only `git status`, `git worktree list`, `gh pr view` / `diff` /
  `checks`, and `gh issue view`, so running the PR's tests, applying fixes, approving, and
  creating worktrees go through the user's normal permission prompts. `commands/devflow-setup.md`
  gets the same treatment, since setup is told not to install anything.
- Bash patterns are prefix matches, so `Bash(git fetch:*)`, `Bash(git log:*)`, `Bash(git diff:*)`,
  `Bash(git branch:*)`, and `Bash(git remote:*)` also approved `--upload-pack=<cmd>`,
  `--output=<file>`, `-D`, and `set-url`. Every wrapper drops them, and `feat` / `epic` narrow
  `gh issue:*` and `gh label:*` to their `view` / `list` forms, so creating issues and labels
  prompts. `feat` keeps its read-only context checks through exact grants with no `:*`,
  `Bash(git branch --show-current)` and `Bash(git remote -v)`, which approve nothing else, and
  its reference names those commands.

### Fixed
- The Claude Code wrappers used `argument-hints` as a YAML list. Claude Code only recognizes
  `argument-hint` with a single string value and silently drops unknown keys, so no hints were
  ever shown. All seven wrappers now use `argument-hint`, and `CLAUDE.md`, `AGENTS.md`, and the
  `SKILL.md` gotchas no longer document the plural form as correct.
- The wrappers and the contributor guidance described `allowed-tools` as a restriction ("using
  Claude Code tools only where allowed by this wrapper", "Restrict `allowed-tools` to minimum
  required"). It only pre-approves tools; every tool stays callable. The wrappers drop the claim,
  and `CLAUDE.md` / `AGENTS.md` now say to grant only what a workflow should run without asking,
  never bare `Bash` for a workflow that executes untrusted code, and `disallowed-tools` to
  actually forbid a tool.
- The OPSX `opsx_validate` template gate fell back to `openspec validate --specs --strict`
  whenever `openspec status` failed, including when the CLI was missing or the change name was
  mistyped, so it could pass without validating the change. It now validates the change when
  its name is among the active changes `openspec list --json` reports, and otherwise runs
  `openspec validate --all --strict`, which covers the main specs and every active change, with
  a note on stderr. The default branch, a detached CI checkout, an unrelated branch, an archived
  change, and a mistyped branch name therefore all still validate the branch's change if it
  exists. An explicit `DEVFLOW_OPENSPEC_CHANGE` is honored strictly: it widens to `--all` only
  once that change is archived, named either way `openspec list --archived` allows. A missing
  CLI, a failing `openspec list`, or a `DEVFLOW_OPENSPEC_CHANGE` naming no active or archived
  change exits `2`, which `check.md` reports as broken configuration, distinct from a validation
  failure (`1`). Both OPSX gates read the branch with `git symbolic-ref`, which works on git
  older than 2.22, and lowercase the name, since `openspec status` matches names
  case-insensitively on macOS but `openspec validate` does not. Both templates carry the
  identical gates, verified against OpenSpec 1.14.1 under `dash`.

### Added
- `docs/skills-best-practices.md`: consolidated Agent Skills authoring guidance from Anthropic,
  OpenAI, the open specification, and skills.sh, with a compliance audit of `skills/devflow/`
  and a prioritized backlog.

## [2.2.1] - 2026-10-13

### Fixed
- The OpenSpec reference is verified against 1.14.1 instead of 1.6.0. Since 1.7, Codex writes its
  skills to the shared vendor-neutral `.agents/skills/` tree, not `.codex/skills/`; the surface
  table, the discovery step, and `setup.md` now say so. The discovery glob already matched the
  new path. Delegation now explicitly allows following a skill found only in another client's
  tree, which is all a Claude Code user with `delivery: commands` will find next to a Codex setup.
- `delivery: commands` no longer reads as "no skills at all": skills-only tools such as Codex
  still get them.
- Changes that own no spec behavior now declare `skip_specs: true` in `.openspec.yaml` (OpenSpec
  1.7+). Without it the `validate <change> --strict` gate fails with `Change must have at least
  one delta`, so recommending `archive --skip-specs` left the gate red until the last step.
  `review-pr.md` treats an unjustified `skip_specs: true` like an unjustified `--skip-specs`.
- The OPSX `check` template gates tested `openspec/changes/<name>` on disk, so they exited `1`
  once the change was archived, which DevFlow does before opening the PR, and never saw
  store-backed changes. They now ask the CLI whether the change is active and otherwise validate
  the main specs with `--strict`.
- The gates derived the change name from the branch's last path segment, which for the default
  `feat/issue-<number>-<slug>` branch is `issue-<number>-<slug>`, while `openspec.md` only said
  the change "usually matches the branch slug". With nothing aligning the two, the gates could not
  find the change. `dev.md` now makes the change name equal the branch's last segment: an
  existing change gives `feat/<change-name>`, and a new change is named `issue-<number>-<slug>`.
  `feat.md` names a change it creates in the issue body so `dev.md` continues it, and the
  templates read `DEVFLOW_OPENSPEC_CHANGE` first, for branches that cannot follow the rule.

### Added
- Notes on stricter `--strict` validation in 1.8–1.14.1: the placeholder `## Purpose` that
  `archive` writes for a new capability now fails `validate --specs --strict`, so `dev.md`
  validates the main specs after archiving.
- A warning not to adopt `openspec validate --archived` as a gate, since it fails on the
  post-merge tasks DevFlow deliberately leaves unchecked.
- A section on store-backed repositories (OpenSpec 1.5+ stores, beta), where changes and main
  specs live in a separate repository and the code PR carries no spec diff.
- `status --all`, `show --diff`, `list --archived`, and `version --json` in the CLI fallback.

## [2.2.0] - 2026-07-30

### Added
- Validation inference now covers Ruby and the JVM, so `check.md` can derive a working gate for
  those projects with no project-local configuration. Ruby runs through `bundle exec` when a
  `Gemfile` is present, so the gems resolved in `Gemfile.lock` are the ones that run, and picks
  the suite the project actually configures. The JVM entry covers Gradle, Maven, and sbt, and
  prefers a committed wrapper over a system install, mirroring the existing lockfile-based
  package manager detection for Node.
- The JVM defaults distinguish the full gate from the `fast` path rather than prescribing both.
  `./gradlew build` already runs `check`, and `./mvnw verify` already runs the `test` phase, so
  pairing either with a separate test invocation would run the suite twice.

### Changed
- The Go inference entry adds `go vet ./...` as its own check, since `go test` runs only a
  high-confidence subset of the vet checks.

Requested in #1, which asked for per-language template directories for Ruby, Java, and Go.
Extending inference covers the same need without adding template trees that would restate
ecosystem commands and drift; Go was already inferred before this release.

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
