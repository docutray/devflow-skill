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
- **Agents**: Autonomous task handlers defined in `agents/<name>.md` with frontmatter specifying `tools`, `model`, and `whenToUse`.

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

| Skill | Version | Description |
|-------|---------|-------------|
| `devflow` | 2.0.0 | Agile development workflow with GitHub integration (feat, dev, check, review-pr, research, epic) |

## Build & Test Commands

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
3. Update version in `skills/devflow/SKILL.md` and `.claude-plugin/marketplace.json`
4. Update `CHANGELOG.md` with notable changes
5. Test locally (see commands above)

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
