# Agent Skills Best Practices

Current authoring guidance for portable Agent Skills, consolidated from Anthropic (Claude Code), OpenAI (Codex), the Agent Skills open specification, and skills.sh. It ends with a compliance audit of `skills/devflow/` and a prioritized backlog.

- **Last reviewed:** 2026-10-13
- **Verified against:** Claude Code 2.1.296, Codex CLI 0.162.1, `npx skills` 1.7.2, `skills-ref` 0.1.1
- **Re-review when:** any of the clients above ships a skill-format change, or before a minor/major DevFlow release.

This page describes the state of the ecosystem on the review date. Rules that differ between sources are listed in [Where Sources Disagree](#where-sources-disagree) instead of being silently resolved.

## Sources

| Area | Primary source |
|---|---|
| Open spec | <https://agentskills.io/specification>, <https://agentskills.io/skill-creation/best-practices>, <https://agentskills.io/skill-creation/optimizing-descriptions>, <https://agentskills.io/skill-creation/using-scripts> |
| Anthropic authoring | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices> |
| Claude Code skills | <https://code.claude.com/docs/en/skills> |
| Claude Code plugins | <https://code.claude.com/docs/en/plugins/components>, <https://code.claude.com/docs/en/plugins/manifest-reference>, <https://code.claude.com/docs/en/plugins/marketplace-reference>, <https://code.claude.com/docs/en/plugin-evals> |
| Anthropic skill-creator | <https://github.com/anthropics/skills/tree/main/skills/skill-creator> |
| Anthropic blog | <https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills> |
| Codex skills | <https://learn.chatgpt.com/docs/build-skills> (formerly `developers.openai.com/codex/skills`) |
| Codex / OpenAI plugins | <https://developers.openai.com/plugins/build/skills>, <https://developers.openai.com/plugins/build/plugins>, <https://developers.openai.com/plugins/guides/submit-claude-plugin>, <https://learn.chatgpt.com/docs/plugins> |
| Codex skill-creator | bundled at `~/.codex/skills/.system/skill-creator/` (source: `openai/codex` `codex-rs/skills/src/assets/samples/skill-creator/`) |
| Codex AGENTS.md | <https://learn.chatgpt.com/docs/agent-configuration/agents-md> |
| skills.sh | <https://skills.sh/docs>, <https://skills.sh/docs/faq>, <https://skills.sh/docs/cli>, <https://skills.sh/docs/customize>, <https://skills.sh/audits>, <https://github.com/vercel-labs/skills> |
| Reference validator | <https://github.com/agentskills/agentskills/tree/main/skills-ref> |

## Validation Toolchain

Run all of these before a release. They check different things, and none of them checks behavior.

```bash
# Marketplace JSON parses
jq empty .claude-plugin/marketplace.json

# Claude Code: authoritative plugin/marketplace check (--strict turns warnings into failures)
claude plugin validate --strict .

# Open-spec validator. The PyPI build installs the executable as `agentskills`, not `skills-ref`
uvx --from skills-ref agentskills validate ./skills/devflow

# Anthropic skill-creator validator (requires PyYAML)
uv run --no-project --with pyyaml python ~/.claude/plugins/marketplaces/claude-plugins-official/plugins/skill-creator/skills/skill-creator/scripts/quick_validate.py ./skills/devflow

# Codex skill-creator validator (requires PyYAML). Stricter key whitelist, see below
uv run --no-project --with pyyaml python ~/.codex/skills/.system/skill-creator/scripts/quick_validate.py ./skills/devflow

# skills.sh discovery: what `npx skills add` would install from this repo
npx skills add . --list
```

| Validator | What it checks | What it does not check |
|---|---|---|
| `skills-ref` (`agentskills validate`) | `SKILL.md` present; strict YAML (no flow style, no duplicate keys); top-level keys limited to `name, description, license, allowed-tools, metadata, compatibility`; `name` rules **including name = directory**; `description` 1–1024; `compatibility` ≤ 500 | body length, file references, `allowed-tools` syntax, `metadata` value types |
| Anthropic `quick_validate.py` | same key whitelist as the spec; `name` regex/length; `description` ≤ 1024 and **no `<` or `>`**; `compatibility` ≤ 500 | name = directory, reserved words, body length |
| Codex `quick_validate.py` | key whitelist **without `compatibility`**; `name` regex/length; `description` ≤ 1024, no `<`/`>`, no `[TODO:` placeholders; no `[TODO:...]` lines in the body | name = directory, body length |
| `claude plugin validate` | marketplace/plugin manifests, reserved names, component paths, unparseable `SKILL.md` frontmatter | wrapper frontmatter keys such as a misspelled `argument-hint` (unknown keys are ignored silently) |

The validators only prove the format. As the Codex skill-creator puts it, the validator "does not prove that the skill makes good decisions". Behavioral checks are covered in [Evaluation](#evaluation-and-iteration).

## Cross-Client Baseline

These rules satisfy every client and validator at once. Treat them as the default for anything under `skills/`.

### Frontmatter

| Field | Rule for a portable skill |
|---|---|
| `name` | Required. 1–64 chars, `[a-z0-9-]`, no leading/trailing hyphen, no `--`, **must equal the directory name**. Avoid the reserved words `claude` and `anthropic`. Prefer a specific name over `helper`/`utils`/`tools`. |
| `description` | Required. 1–1024 chars, no `<` or `>`, no XML tags. Third person. Says **what** the skill does and **when** to use it. Put the key use case and trigger words first, because Claude Code and Codex both shorten descriptions under budget pressure. |
| `license` | Optional. A license name, or a reference to a bundled file. If you declare one, ship the file. |
| `metadata` | Optional string→string map. Quote values (`version: "2.2.1"`). Use reasonably unique keys. |
| `compatibility` | Optional, ≤ 500 chars, and only for genuine environment requirements ("most skills do not need" it). The spec, Claude Code, and the Codex runtime accept it, but **the Codex `quick_validate.py` rejects it**. |
| `allowed-tools` | Optional and experimental in the spec. Claude-flavored, so keep it out of portable skills unless the skill needs it. |
| anything else | Do not use under `skills/`. claude.ai uploads, the Skills API, `package_skill.py`, `skills-ref`, and both `quick_validate.py` scripts hard-fail on unknown keys. Claude Code and Codex ignore them silently. |

### Descriptions

- Use the shape `<What it does>. Use when <contexts, user phrasings, keywords>.` Focus on the user's intent, not on implementation details.
- Keep it as short as the triggers allow. OpenAI's guidance says descriptions should be "as short as possible while making it clear when the model should use them". Avoid exhaustive capability lists and catch-alls ("use when working with databases…") that attract unrelated requests. Add exclusions only when they prevent likely misrouting.
- Anthropic's skill-creator notes that Claude tends to under-trigger and recommends "a little bit pushy" phrasing. Counterweight: simple one-step requests may not trigger any skill, whatever the description says.
- Put all "when to use" information in the description. The body loads only after the skill has triggered.
- Do not list client-specific invocation syntax (slash commands, `$skill` mentions) in a portable description. It spends budget and means nothing in other clients.

### Body Size and Progressive Disclosure

- Disclosure happens in three tiers. Metadata (~100 tokens) is always loaded. The `SKILL.md` body (< 5,000 tokens, < 500 lines) loads when the skill activates. Resources load only on demand. The newer Codex skill-creator drops the hard numbers: "A large upper bound is not a target."
- Make a multi-workflow `SKILL.md` a minimal router. Each link should say **when** to read the target ("Read `references/x.md` when …"), not "see references/".
- Keep references **one level deep** from `SKILL.md`. Codex's system prompt explicitly says "Avoid deep reference-chasing", and nested references lead Claude to partial reads.
- Give long reference files a table of contents or grep hints. The threshold is 100 lines on the Anthropic platform page and 300 lines in skill-creator.
- Keep each fact in one place: either in `SKILL.md` or in a reference, never both.
- Keep gotchas in `SKILL.md`, and put the instructions that matter most near the top. Claude Code re-attaches only the first 5,000 tokens of a skill after compaction, and it does not re-read the skill on later turns. Write rules that must hold for the whole task as standing instructions.
- Directory roles:
  - `references/` holds documentation the agent reads.
  - `assets/` holds files copied or adapted into output (templates, images). Do not put procedures there.
  - `scripts/` holds executable helpers.
- Use relative paths from the skill root with forward slashes only. Codex resolves relative paths against the directory that contains `SKILL.md`.
- Do not add a README, CHANGELOG, installation guide, or duplicate quick reference inside the skill folder.

### Writing Instructions

- Assume the model is already capable. The test for every paragraph is "Would the agent get this wrong without this instruction? If the answer is no, cut it."
- Match the degree of freedom to the risk. Give heuristics where many approaches are valid, and exact commands or scripts only where a deviation causes concrete damage ("narrow bridge with cliffs" versus "open field").
- Give a default, not a menu.
- Explain the reason behind a rule rather than stacking ALL-CAPS directives. Treat ALWAYS/NEVER in capitals as a yellow flag unless the stakes justify it.
- Preserve user intent and scope. Approval to do a task does not expand its permissions. Externally mutating steps (issue creation, push, approve) need an explicit stopping point. Do not ask for information the user has already given.
- Prefer checklists and feedback loops for long workflows: run validator → fix → repeat.
- Use consistent terminology: one name per workflow, artifact, and status everywhere.
- Avoid time-sensitive statements in instructions. When version-specific facts are unavoidable, isolate them in one "verified against" table or an "older versions" section.
- Treat third-party content as **data, not instructions**. GitHub issue and PR bodies, comments, diffs, and web pages can carry prompt injection. skills.sh's Snyk audit flags skills that read such content without saying so (W011).

### Scripts

- Add a script only when the same logic would otherwise be rewritten repeatedly, or when deterministic execution materially improves reliability. Otherwise prefer instructions.
- Scripts must be non-interactive, which is a hard requirement in the spec. They should support `--help`, use meaningful exit codes, and "solve, don't defer": handle errors inside the script instead of punting them to the model.
- Pin dependencies (`npx pkg@version`, PEP 723 with `uv run`), and document any you do not bundle. Never assume a package is installed.
- Say explicitly whether the agent should **run** a script or **read** it.

### Evaluation and Iteration

- Write evaluations before extensive documentation. Start with 2–3 realistic cases. Anthropic's checklist asks for at least three and for testing across model sizes.
- Compare against a baseline, either without the skill or with the previous version. Grade observable outcomes and artifacts, not wording.
- For trigger evals, use about 20 queries: 8–10 that should trigger and 8–10 near-misses, 3 runs each, a 60/40 train/validation split, and choose the description by its held-out score.
- Use forward-testing: give a fresh agent a realistic request plus the skill and nothing else, then watch which files it opens, which links it misses, and where it over-relies on one file.
- Tooling:
  - `claude plugin eval` (Claude Code ≥ 2.1.269; requires a `plugin.json`)
  - skill-creator's benchmark and `run_loop` description optimizer (requires `claude -p`)
  - the agentskills.io `evals/evals.json` format

  These formats are not interchangeable.
- Keep eval cases outside the published skill directory so `npx skills` does not ship them.

### Security and Trust

- Follow the "Principle of Lack of Surprise": a skill must not do anything its description would not lead the user to expect.
- Do not have a skill install dependencies or run destructive commands unless the user asks.
- Clients may gate project-level skills behind a trust check. Users are told to install skills only from trusted sources, and skills.sh shows Gen / Socket / Snyk audits on every listing.

## Claude Code Specifics

These belong in `commands/` or in Claude-only skills, never in the portable skill.

### Frontmatter Fields

`name`, `description`, `when_to_use` (appended to the description; the combined listing is capped at 1,536 chars), `argument-hint` (**singular**, one string), `arguments`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `disallowed-tools`, `model`, `effort`, `context: fork`, `agent`, `background`, `hooks`, `paths`, `shell`. Command files accept the same fields except `name` and `paths`.

- **`allowed-tools` pre-approves; it does not restrict.** "Every tool remains callable." To actually remove tools while a skill or command is active, use `disallowed-tools`. A bare `Bash` grant pre-approves every shell command for that turn.
- Body substitutions are `$ARGUMENTS`, `$N`, `$name`, `${CLAUDE_SKILL_DIR}`, `${CLAUDE_PROJECT_DIR}`, and, in plugins, `${CLAUDE_PLUGIN_ROOT}` and `${CLAUDE_PLUGIN_DATA}`. Plugin variables are substituted in Markdown bodies only; they are not in the Bash environment.
- `` !`cmd` `` runs dynamic context. A failing command aborts the invocation.
- A rule that must hold every time belongs in a hook, not in prose.
- The skill listing budget is 1% of the context window, tunable with `skillListingBudgetFraction`. When it overflows, the descriptions of the least-used skills are dropped first.

### Commands Versus Skills

- "Custom commands have been merged into skills." In plugins, `commands/` is "the older format, and skills supersede them for new work". It still loads and is not deprecated.
- Naming: `commands/<file>.md` becomes `/<plugin>:<file>`, and `skills/<dir>/SKILL.md` becomes `/<plugin>:<dir>`.
- To migrate a wrapper to a skill, set `disable-model-invocation: true` so it does not compete with the canonical skill for auto-triggering. Keep it out of any directory that `npx skills` scans, otherwise it ships to every client.

### Plugins and Marketplaces

- `.claude-plugin/` contains only the manifests. Component paths start with `./` and contain no `..`.
- Without a `plugin.json`, the marketplace entry is the manifest. When `source` is the marketplace root and the entry lists `skills`, only those subdirectories load. `commands/` is still scanned by default.
- `strict: false` combined with a `plugin.json` that also declares components is a "conflicting manifests" error.
- If both exist, the `plugin.json` `version` wins over the marketplace entry's.
- Reserved names: plugin names cannot start with `claude-`, `anthropic-`, `anthropics-` or `cc-plugin-`. The marketplace reserved-names list includes `agent-skills`.
- A `CLAUDE.md` at the plugin root is not loaded.

## Codex Specifics

### Discovery and Invocation

- Repository skills live in `.agents/skills/`, scanned from the repository root down to the working directory. User skills live in `~/.agents/skills`, admin skills in `/etc/codex/skills`, and system skills are bundled. `~/.codex/skills` still loads but is marked deprecated in the source, even though the bundled skill-creator still writes there.
- Explicit invocation is `/skills` or a `$skill-name` mention. Implicit invocation is a description match. Codex's system prompt tells the model to read `SKILL.md` completely, follow its routing, read references itself (not through a subagent), prefer existing `scripts/` and `assets/`, and announce which skill it is using.
- The metadata budget is 2% of the context window (8,000 chars when unknown). Descriptions are truncated at 1,024 chars and shortened further when many skills are installed.
- Codex parses only `name`, `description`, and `metadata.short-description`. Other keys are ignored, not rejected.

### `agents/openai.yaml`

This optional file is ignored by other clients, so it is safe to ship inside a portable skill.

- `interface`: `display_name`; `short_description` (25–64 chars); `icon_small` / `icon_large` under `./assets/`; `brand_color`; `default_prompt`, which must mention `$skill-name`.
- `policy.allow_implicit_invocation`: defaults to `true`. Keep it unless the user wants an explicit-only skill. Do not infer explicit-only from sensitive operations; require authorization at the mutation instead.
- `dependencies.tools[]`: `type: mcp` only.
- Quote all string values. An invalid file is ignored with a warning.

### Plugins

- Codex reads `.claude-plugin/marketplace.json` and `.claude-plugin/plugin.json` as legacy-compatible fallbacks. New OpenAI packages should use a root `plugin.json` with the agent-plugins.org `$schema`, in which skills inside portable packages are truncated at 8,000 bytes.
- On install, Codex converts Claude `commands/*.md` into `source-command-<name>` skills. It skips any command that uses `$ARGUMENTS`, `$1`, `@file`, or `` !` ``, or that exceeds 4,000 bytes.
- OpenAI's submission guide asks for provider-neutral wording ("the model") in skill instructions.

### AGENTS.md

AGENTS.md is always loaded, concatenated from the root down, with a 32 KiB default cap. Put always-on repository norms there and on-demand procedures in skills. Use contextual pointers ("Use `architecture.md` for service boundaries") rather than "before every edit, read …".

## skills.sh Specifics

- **Discovery order in a source repo:**
  1. A root `SKILL.md`. If present, only that skill is returned unless `--full-depth` is set.
  2. `skills/`, walked up to three levels deep.
  3. About 60 agent directories (`.agents/skills`, `.claude/skills`, …), excluding skills tracked as installed in `skills-lock.json`.
  4. Skills declared in `.claude-plugin/marketplace.json` or `plugin.json`. Paths must start with `./`, and entries that don't are skipped silently.
  5. A recursive fallback search.

  Skills are de-duplicated by frontmatter `name`, and the first one found wins.
- `--skill` matches the frontmatter `name`, case-insensitively.
- A skill without both `name` and `description` as strings is skipped with a warning.
- Installs go to `.agents/skills/<name>`, with a symlink in each agent's directory. Codex and most other agents share `.agents/skills/`, and Claude Code uses `.claude/skills/`.
- Listing has no submission step. A skill appears through anonymous install telemetry from public GitHub repositories, and rankings come from that telemetry. The FAQ only asks for "a GitHub repository with a skill definition file and a README explaining its use".
- An optional root `skills.sh.json` (`groupings`, `notGrouped`) changes only how the listing displays.
- Every listing shows Gen Agent Trust Hub, Socket, and Snyk audits. They never block an install. What triggers a re-audit is not documented.

## Where Sources Disagree

| Topic | Positions | Portable choice |
|---|---|---|
| `compatibility` field | Spec, Anthropic validator, Claude Code, Codex runtime: allowed. Codex `quick_validate.py`: rejected. | Use it only for real requirements, and accept the known Codex validator failure, or move the requirements into the body. DevFlow moved them into the body in 2.3.0. |
| Description length | Spec/API: 1024. Claude Code listing: 1,536 (description + `when_to_use`). Codex: truncated under budget pressure. | ≤ 1024 and front-loaded; much shorter is better. |
| Description tone | Anthropic skill-creator: "pushy" to fight under-triggering. OpenAI: as short as possible, no catch-alls. | Specific trigger phrasings and boundaries, no capability lists. |
| Table of contents threshold | Platform docs: 100 lines. skill-creator: 300 lines. | Add one past ~100 lines. |
| Name = directory | Spec and `skills-ref`: required. Claude Code and both `quick_validate.py` scripts: not enforced. | Always match. |
| Emphatic wording | Platform docs: "MUST" can fix a missed rule. skill-creator and agentskills.io: explain the why instead. | Explain the reason; reserve emphasis for safety. |
| Size limit | Spec and Anthropic: < 500 lines / < 5k tokens. New Codex skill-creator: no number, "as short as the task permits". | Treat 500 lines as a ceiling, not a target. |
| Codex user skill path | Docs: `~/.agents/skills`. Bundled installer: `~/.codex/skills` (deprecated in code). | `.agents/skills` / `~/.agents/skills`. |

## DevFlow Compliance Audit (2026-10-13)

Inputs to this audit:

- every validator above, run against `main` at `72b596d`
- an install test of the marketplace in an isolated `CODEX_HOME`
- read-only reviews by the Claude Code skill-creator (`claude -p`) and the Codex skill-creator (`codex exec --sandbox read-only`)
- the skills.sh audit page for this repository

### Automated Results

| Check | Result |
|---|---|
| `jq empty .claude-plugin/marketplace.json` | pass |
| `claude plugin validate --strict .` | pass |
| `skills-ref` (`agentskills validate skills/devflow`) | pass |
| Anthropic `quick_validate.py` | pass |
| Codex `quick_validate.py` | **fail**: `Unexpected key(s) in SKILL.md frontmatter: compatibility`. Passes since 2.3.0 (row 6). |
| `npx skills add . --list` | discovers 1 skill, `devflow`, grouped under the marketplace plugin |
| `codex plugin marketplace add ./` + `codex plugin add devflow@docutray-skills` | pass. Codex accepts the Claude marketplace and installs `skills/devflow`. The `commands/` wrappers are not migrated (they use `$ARGUMENTS` / `@`), which is expected and harmless. |
| skills.sh audits | Gen: Pass. Socket: Pass. **Snyk: Warn (W011, third-party content exposure / indirect prompt injection)**, citing `references/dev.md`, `review-pr.md`, `research.md`. |
| Sizes | `SKILL.md` 92 lines / 7,679 bytes; references 38–131 lines; description 518 chars; `compatibility` 259 chars. All 24 local links resolve. |

### Already Compliant

- The name `devflow` is valid and matches its directory. The frontmatter uses only spec keys, and `metadata.version` is a quoted string.
- `SKILL.md` is a short router: one reference per workflow, each linked one level deep with a clear "read when" condition. The gotchas are in the entrypoint.
- Degrees of freedom are well calibrated. Rules are firm where mistakes are costly (archive with spec sync, post-merge tasks, legacy config location, ignore only `.devflow/worktrees/`) and flexible for research and review.
- OpenSpec skills are resolved at run time by purpose, with a CLI fallback and an announcement of the chosen path. This matches the Codex skill-creator rule to refer to other skills only when they are available.
- Command inference prefers the project's own scripts and CI, and package-manager detection uses lockfiles.
- Approval and autofix require matching user intent.
- Claude wrappers are thin and delegate all behavior to the references. Configuration lives in the client-neutral `.devflow/`.

### Gaps

Priority: **P1** fix before the next release; **P2** fix soon; **P3** opportunistic.

| # | P | Finding | Where | Recommended fix |
|---|---|---|---|---|
| 1 | P1 | **Fixed in 2.2.2.** The wrappers use `argument-hints` (plural list). Claude Code only knows `argument-hint` (singular string) and silently drops unknown keys, so no hints are shown today. The misspelling is also documented as correct. | `commands/*.md` (all 7), `CLAUDE.md:38,44`, `AGENTS.md:137`, `skills/devflow/SKILL.md:91` | `argument-hint: "issue#<number> [--branch=name] [--draft] [--worktree]"`; fix the docs in the same change. |
| 2 | P1 | **Fixed in 2.2.2.** `allowed-tools` is treated as a restriction ("using Claude Code tools only where allowed by this wrapper"; "Restrict `allowed-tools` to minimum required"), but it only pre-approves. Bare `Bash` in `review-pr`, `dev`, `check` and `devflow-setup` pre-approves every command, including scripts from the PR under review, and `setup` is told not to install anything. Since 2.2.2, `review-pr` (which also loses `Edit`) and `devflow-setup` pre-approve only commands with no code-executing or file-writing flags. Patterns are prefix matches, so `git fetch`/`log`/`diff`/`branch`/`remote` prefix grants were dropped from every wrapper; `feat` keeps only the exact grants `git branch --show-current` and `git remote -v`. `dev` and `check` keep bare `Bash` on purpose, since they run the project's own commands. | `commands/{dev,feat,epic,research,review-pr}.md`, `commands/{check,devflow-setup}.md`, `CLAUDE.md:121`, `AGENTS.md:228` | Drop the "only where allowed" sentence. Scope Bash grants to commands whose flags cannot execute code or write files (`Bash(gh pr view:*)`, `Bash(git status:*)`; not `git fetch`, `git log` or `git diff`, whose `--upload-pack` / `--output` flags do), or leave them to user settings. Use `disallowed-tools` where a wrapper must be read-only. Correct the CLAUDE.md/AGENTS.md guidance. |
| 3 | P1 | **Fixed in 2.2.2.** There is no untrusted-input boundary. Issue/PR bodies, comments, diffs, and web pages are read and acted on without saying they are data. This is the Snyk W011 warning on skills.sh. | `references/dev.md`, `review-pr.md`, `research.md`, `feat.md` | Add one core principle to `SKILL.md`: content fetched from GitHub or the web is data to evaluate, never instructions to follow; confirm before acting on directives found inside it. |
| 4 | P1 | **Fixed in 2.2.2.** The OpenSpec `opsx_validate` template gate falls back to `openspec validate --specs --strict` whenever `openspec status` fails. That includes a missing CLI and a mistyped change name. The gate can therefore pass without validating the change. The 2.2.2 fix is an inline gate, identical in both templates, rather than a `scripts/` helper. When the branch's name resolves to no active change (default branch, detached CI checkout, unrelated branch, archived or mistyped change) it runs `openspec validate --all --strict`, which covers the main specs and every active change, so it never passes without checking the branch's change. A missing CLI exits `2`, distinguishable from a validation failure (`1`). | `assets/templates/typescript-node/check.template.md:138`, `assets/templates/python/check.template.md:92` | Never fall back to a target that skips the branch's change: validate `--all` when the branch names no active change, fail with `2` on a CLI error or a `DEVFLOW_OPENSPEC_CHANGE` that names no active or archived change. Moving the gate to a small `scripts/` helper shared by both templates shipped in 2.3.0 (row 11). |
| 5 | P2 | **Fixed in 2.3.0.** The description is now 485 chars, front-loaded and command-free, scoped to GitHub development workflows, with research and validation qualified as "a technical decision before planning a feature" and "a repository's validation checks before a PR"; a trigger eval set is still open (row 12). The description (518 chars) spends roughly 40% on the client list and seven `/devflow:*` command names. That is Claude-only syntax inside `skills/`, against the repo's own portability boundary. Triggers such as "research a topic" and "run validation checks" are catch-alls. | `SKILL.md:3` | Rewrite it front-loaded and command-free, scoped to GitHub development workflows and repository decisions. Validate with a trigger eval set. |
| 6 | P2 | **Fixed in 2.3.0.** The field is dropped and its facts live in a one-line "Requirements" note in the `SKILL.md` body, so every validator passes; `CLAUDE.md` and `AGENTS.md` list the Codex validator with the rest. The Codex skill-creator validator rejects `compatibility`. | `SKILL.md:5` | Decide explicitly. Either keep the field (spec-valid, ignored by the Codex runtime) and document the known failure in CLAUDE.md/AGENTS.md, or move the requirements into a short "Requirements" line in the body and drop the field so that every validator passes. |
| 7 | P2 | **Fixed in 2.3.0.** It is now `references/worktrees.md`, linked from `SKILL.md`, `dev.md`, `review-pr.md`, `epic.md`, and `setup.md`, with host-neutral wording, POSIX snippets, `--force` only on the user's explicit request, and the legacy `.claude/worktrees/` used and cleaned up but never created. `worktree-guide.md` is a procedure stored under `assets/` and reached two levels deep. It says "Bash tool calls" (a Claude tool name) in CRITICAL style, offers `git worktree remove --force` with no authorization boundary, and ignores the legacy `.claude/worktrees/`. | `assets/templates/worktree-guide.md:54,89` | Move it to `references/worktrees.md`, link it from `SKILL.md`, use host-neutral wording ("set the working directory explicitly"), and require an explicit user request before `--force`. |
| 8 | P2 | **Fixed in 2.3.0.** `SKILL.md` defines the resolution rule once and `feat`, `dev`, `check`, and `review-pr` apply it as step 1, so `dev` knows the branch convention before choosing a branch; `references/check.md` documents the JSON format with a minimal example. Project configuration routing is incomplete. `feat` and `review-pr` never load `.devflow/feat.md` / `review-pr.md`. `dev` loads `.devflow/dev.md` at step 7, after the branch convention has been chosen. The `.devflow/check.md` JSON shape (`validations.{command,enabled,skip_on_fast}`) is defined only in the templates. | `references/feat.md`, `review-pr.md`, `dev.md:24`, `check.md:14` | Resolve the workflow's config first in every workflow, and document the `check.md` format in `references/check.md`. |
| 9 | P2 | **Fixed in 2.3.0.** `references/check.md` infers `cargo build`, `cargo test`, `cargo fmt --check`, and `cargo clippy -- -D warnings` when clippy is installed, with `cargo test` as the `fast` path. Rust is offered by setup but has no inference rule in validation. | `commands/devflow-setup.md`, `references/setup.md:7`, `references/check.md:15-43` | Add a `cargo build` / `cargo test` / `cargo clippy -- -D warnings` / `cargo fmt --check` rule, with `cargo test` as the `fast` path. |
| 10 | P2 | **Fixed in 2.3.0.** `feat`, `epic`, and `research` ask only when the request leaves the description or decision unclear. The planning workflows ask for a description unconditionally, even when the request already contains one. | `references/feat.md:14`, `epic.md:14` | "If the request does not already describe it, ask …". |
| 11 | P2 | **Fixed in 2.3.0.** The gate mechanics live only in `openspec.md` ("The Validation Gate"), `SKILL.md` keeps one slash-command gotcha, and the `opsx_validate` gate is a shared POSIX script, `assets/scripts/opsx-validate.sh`, that setup copies to `.devflow/scripts/` and both templates run. Rules are duplicated. OpenSpec gate mechanics appear in `check.md:45`, `dev.md`, and `openspec.md`. The slash-command caveat appears three times in `SKILL.md` (lines 17–22, 49, 90–92), and every workflow-map bullet repeats "or mentions `/devflow:X`". | `references/check.md:45`, `SKILL.md` | Keep OpenSpec mechanics only in `openspec.md` and link to them. Keep one gotcha about optional slash commands. |
| 12 | P2 | There are no evals. | repo | Add 3–4 behavioral cases plus a trigger set outside `skills/`, for example `evals/devflow/`: OpenSpec repo without `openspec-apply-change`; no-config check inference for pnpm, Gradle, and Rust; setup with a legacy `.claude/details/commands/check.md`; a PR that defers a test as post-merge work. |
| 13 | P3 | `openspec.md` is 131 lines with no table of contents. | `references/openspec.md` | Add a short contents list. |
| 14 | P3 | The wrappers grant `Task` and `TodoWrite`. Claude Code's subagent tool is now `Agent`, and neither entry needs a pre-approval. | `commands/*.md`, `CLAUDE.md:45` | Remove them, and say "subagents" in prose. |
| 15 | P3 | The validation report template omits the `warning` status it defines and has no OpenSpec row. | `references/check.md:46-60` | Align the template with step 5. |
| 16 | P3 | Terminology drifts: "Implementation" / "development workflow" / "dev", "Validation" / "check", "OPSX/OpenSpec" / "OpenSpec", and "Dependencies and risks" in the steps versus "Dependencies" + "Considerations" in the template. | `SKILL.md`, `references/feat.md:24` | Pick one display name per workflow. |
| 17 | P3 | The `dev` templates (326–353 lines) are mostly generic tutorial content. Some template commands are dated: `safety check` (now `safety scan`); flake8 + black + isort as the Python default rather than ruff; `--frozen-lockfile` for Yarn 2+ (now `--immutable`). | `assets/templates/*/dev.template.md`, `python/check.template.md:16` | Trim the templates to project command slots, conventions, and gotchas, and refresh the defaults. |
| 18 | P3 | `license: MIT` is declared but the repository has no `LICENSE` file. | repo root | Add `LICENSE`. |
| 19 | P3 | Time-sensitive facts are scattered: "published 2026-10-06", "on 1.14.1", "Since 1.7", "1.5 added stores (beta)", "DevFlow 2.0 and earlier". | `references/openspec.md`, `SKILL.md:76` | Keep the "Verified against" table, and move version history into one "Older OpenSpec versions" section. |
| 20 | P3 | There is no `agents/openai.yaml`. This is not a defect (implicit invocation defaults on). Adding it would give Codex a display name, a short description, and a `$devflow` default prompt. | `skills/devflow/` | Optional: `interface.display_name: "DevFlow"`, `short_description` of 25–64 chars, `default_prompt: "Use $devflow to implement issue #123."` |
| 21 | P3 | A local-path marketplace install copies untracked files, such as `.claude/settings.local.json`, into the Codex plugin cache. Installs from GitHub are unaffected because the file is gitignored. | `.claude/` | Test local installs from a clean checkout. |

### Decisions Kept On Purpose

- **`commands/` stays as Claude Code wrappers for now.** `commands/` is the older format but still supported. Moving the wrappers into `skills/` would publish them through `npx skills` and add seven descriptions that compete with `devflow` for auto-triggering. If they are ever migrated, put them outside the scanned `skills/` tree, list them in the marketplace `skills` array, and set `disable-model-invocation: true`.
- **No `plugin.json`.** The marketplace entry acts as the manifest for both Claude Code and Codex. Adding one becomes necessary only to use `claude plugin eval` or the agent-plugins.org portable format. In that case remove `strict: false`, or stop declaring components in the entry, to avoid the "conflicting manifests" error.
