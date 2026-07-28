# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a **portable Agent Skill repository** for the Docutray organization. DevFlow is distributed through `npx skills` for skills-compatible agents and through a Claude Code marketplace entry that installs the same skill plus slash command wrappers. This is NOT an application codebase.

## Repository Structure

```
devflow-skill/
├── .claude-plugin/
│   └── marketplace.json      # Central marketplace catalog
├── skills/
│   └── devflow/              # Canonical Agent Skill
│       ├── SKILL.md
│       ├── references/
│       └── assets/templates/
├── commands/                 # Claude Code slash command wrappers
├── AGENTS.md                 # Detailed context for AI coding agents
└── CHANGELOG.md              # Version history
```

## Skill Architecture

### Canonical Skill

`skills/devflow/SKILL.md` is the source of truth. Keep it concise and move detailed workflows to `skills/devflow/references/`. Templates and reusable resources live under `skills/devflow/assets/`.

### Marketplace (`marketplace.json`)

The root `.claude-plugin/marketplace.json` exposes the `devflow` plugin with `source: "./"` and `skills: ["./skills/devflow"]` so Claude Code installs the same Agent Skill used by `npx skills`.

### Key Concepts

- **Skills**: Auto-activated by agents based on trigger terms in the `description` field of `SKILL.md` frontmatter. Located in `skills/<skill-name>/SKILL.md`.
- **Commands**: Claude Code wrappers in root `commands/`. They delegate to the canonical skill references and may use Claude-specific frontmatter (`allowed-tools`, `argument-hints`).

### Portability Boundary

This is the constraint that spans the whole repo: `skills/devflow/` must run unchanged in Codex and other Agent Skills clients, so Claude-only constructs live **only** in `commands/` and must never leak into `skills/`:

- `allowed-tools`, `argument-hints`, `${CLAUDE_PLUGIN_ROOT}`, `$ARGUMENTS`/`$1`, `@file` references
- Claude-specific tool names (`Task`, `AskUserQuestion`, `TodoWrite`, `WebSearch`)
- Any assumption that slash commands exist at all

Every wrapper follows the same shape: read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/SKILL.md`, read the matching `references/<workflow>.md`, treat `$ARGUMENTS` as the request, then follow the reference. Behavior changes belong in the reference; only tool permissions and argument hints belong in the wrapper. Claude Code derives the command name from the filename, so `commands/dev.md` → `/devflow:dev`.

### Two Kinds of Config — Don't Confuse Them

`.devflow/{check,feat,dev,review-pr}.md` is project-local config that DevFlow **reads in the repositories that install it**. It does not exist in this repo and should not be created here. `skills/devflow/assets/templates/` holds the examples the setup workflow adapts when generating those files in a consumer repo.

The legacy location is `.claude/details/commands/`, still read for backward compatibility but never written. The canonical path is client-neutral because Codex is a first-class target and must not have a `.claude/` directory written into its repositories.

### Distribution

```bash
# Agent Skills
npx skills add https://github.com/docutray/devflow-skill --skill devflow

# Users add the marketplace
/plugin marketplace add docutray/devflow-skill

# Users install the plugin
/plugin install devflow@docutray-skills
```

## Current Skill

`devflow` — agile development workflow with GitHub integration (setup, feat, dev, check, review-pr, research, epic). The version is not restated here on purpose; see the sources of truth below.

## Build & Test Commands

There is no build step or test suite. Validation is manifest linting plus manual installation testing.

```bash
jq empty .claude-plugin/marketplace.json    # marketplace JSON must parse
skills-ref validate ./skills/devflow        # if available: Agent Skill frontmatter check
```

### Skill And Plugin Integration Testing

```bash
npx skills add . --skill devflow

/plugin marketplace add .                  # Add local marketplace
/plugin install devflow@local              # Install for testing

# After changes, uninstall and reinstall to refresh
/plugin uninstall devflow && /plugin install devflow@local
```

Use `claude --debug` to troubleshoot plugin loading issues.

## Development Workflow

1. Add or modify canonical skill files in `skills/devflow/`
2. Keep Claude Code wrappers in `commands/` thin and delegated to the skill
3. Bump the version in **all four** places — they drift easily:
   - `skills/devflow/SKILL.md` (`metadata.version`)
   - `.claude-plugin/marketplace.json` (`plugins[0].version`)
   - `README.md` (`Current version:`)
   - `AGENTS.md` (plugin table)
4. Update `CHANGELOG.md` with notable changes
5. Test locally (see commands above)

`AGENTS.md` carries the long-form version of this guidance (marketplace schema, release/tag steps, troubleshooting) for non-Claude agents. When a process changes, update it there too rather than letting the two files diverge.

### Adding a New Workflow

1. Add the detailed workflow under `skills/devflow/references/<workflow>.md`
2. Link it from `skills/devflow/SKILL.md` with clear activation guidance
3. Add a root `commands/<workflow>.md` wrapper only if Claude Code command UX is needed
4. Use `/devflow:<command-file-name>` as the documented Claude Code command name

### Adding Commands and Skills

- **Command**: Create `.md` file in `commands/` with YAML frontmatter. Restrict `allowed-tools` to minimum required and delegate behavior to the skill.
- **Skill**: Create `skills/<skill-name>/SKILL.md` with `name` (lowercase-hyphen, max 64 chars) and `description` (must include trigger terms, max 1024 chars).

## Code Style

### Markdown
- YAML frontmatter for metadata, ATX-style headers, code blocks with language specifiers

### JSON
- 4-space indentation

## Official References

- [Plugins Overview](https://docs.claude.com/en/docs/claude-code/plugins)
- [Plugins Reference](https://docs.claude.com/en/docs/claude-code/plugins-reference)
- [Slash Commands](https://docs.claude.com/en/docs/claude-code/slash-commands)
- [Agent Skills Specification](https://agentskills.io/specification)
- [skills.sh Documentation](https://skills.sh/docs)
