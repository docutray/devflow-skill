# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a **Claude Code plugin marketplace** for the Docutray organization. It contains multiple reusable plugins with slash commands and skills that can be installed across different projects. This is NOT an application codebase - it's a collection of plugin components organized as a marketplace.

## Repository Structure

```
docutray-claude-code-plugins/
├── .claude-plugin/
│   └── marketplace.json      # Central marketplace catalog
├── plugins/
│   └── devflow/              # Agile workflow commands (pure markdown)
│       ├── .claude-plugin/plugin.json
│       ├── commands/         # Slash commands (.md with YAML frontmatter)
│       └── templates/        # Framework-specific templates (python, typescript-node)
├── AGENTS.md                 # Detailed context for AI coding agents
└── CHANGELOG.md              # Version history
```

## Plugin Architecture

### Marketplace (`marketplace.json`)

The root `.claude-plugin/marketplace.json` lists all plugins with `source` paths relative to the marketplace root (e.g., `"source": "./plugins/devflow"`). Each plugin also has its own `.claude-plugin/plugin.json` manifest with version and metadata.

### Key Concepts

- **Commands**: User-invoked via `/plugin:command-name`, defined in `.md` files with YAML frontmatter (`description`, `allowed-tools`, `argument-hint`). Support `$ARGUMENTS`, `$1`/`$2`, `` !`bash` `` execution, `@file` references, and `${CLAUDE_PLUGIN_ROOT}`.
- **Skills**: Auto-activated by Claude based on trigger terms in the `description` field of `SKILL.md` frontmatter. Located in `skills/<skill-name>/SKILL.md`.
- **Agents**: Autonomous task handlers defined in `agents/<name>.md` with frontmatter specifying `tools`, `model`, and `whenToUse`.

### Plugin Distribution

```bash
# Users add the marketplace
/plugin marketplace add docutray/docutray-claude-code-plugins

# Users install the plugin
/plugin install devflow@docutray-plugins
```

## Current Plugins

| Plugin | Version | Description |
|--------|---------|-------------|
| `devflow` | 1.3.0 | Agile development workflow with GitHub integration (feat, dev, check, review-pr, research, epic) |

## Build & Test Commands

### Plugin Integration Testing (in Claude Code)

```bash
/plugin marketplace add .                  # Add local marketplace
/plugin install devflow@local              # Install for testing

# After changes, uninstall and reinstall to refresh
/plugin uninstall devflow && /plugin install devflow@local
```

Use `claude --debug` to troubleshoot plugin loading issues.

## Development Workflow

1. Add or modify plugin files in `plugins/<plugin-name>/`
2. Update version in `plugins/<plugin-name>/.claude-plugin/plugin.json`
3. Update version in `.claude-plugin/marketplace.json` if needed
4. Update `CHANGELOG.md` with notable changes
5. Test locally (see commands above)

### Adding a New Plugin

1. Create `plugins/<name>/` with `.claude-plugin/plugin.json`, `commands/`, and `README.md`
2. Register in `.claude-plugin/marketplace.json` with `name`, `source`, `description`, `version`, `category`

### Adding Commands and Skills

- **Command**: Create `.md` file in `commands/` with YAML frontmatter. Restrict `allowed-tools` to minimum required.
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
- [Skills](https://docs.claude.com/en/docs/claude-code/skills)
