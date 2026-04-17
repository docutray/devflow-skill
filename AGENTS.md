# AGENTS.md - Docutray Claude Code Plugins

This file provides essential context for AI coding agents working with the Docutray Claude Code Plugins repository.

## Project Overview

This is a **Claude Code plugin marketplace** maintained by the Docutray organization. It contains reusable plugins with slash commands and skills that extend Claude Code's capabilities for software development workflows.

**Important**: This is NOT a traditional application codebase. It's a collection of plugin components organized as a marketplace for distribution through Claude Code's plugin system.

### Current Plugins

| Plugin | Version | Description | Category |
|--------|---------|-------------|----------|
| `devflow` | 1.3.0 | Complete agile development workflow with GitHub integration | development |

## Repository Structure

```
docutray-claude-code-plugins/
├── .claude-plugin/
│   └── marketplace.json          # Central marketplace catalog
├── plugins/
│   └── devflow/                  # DevFlow plugin (agile workflow)
│       ├── .claude-plugin/
│       │   └── plugin.json       # Plugin manifest
│       ├── commands/             # Slash command definitions (.md files)
│       │   ├── feat.md
│       │   ├── dev.md
│       │   ├── check.md
│       │   ├── review-pr.md
│       │   ├── research.md
│       │   ├── epic.md
│       │   └── devflow-setup.md
│       ├── templates/            # Framework-specific templates
│       │   ├── python/
│       │   └── typescript-node/
│       └── README.md
├── README.md                     # Marketplace documentation
├── CLAUDE.md                     # Claude Code guidance
├── CHANGELOG.md                  # Version history
└── AGENTS.md                     # This file
```

## Technology Stack

### Repository Level
- **Version Control**: Git
- **License**: MIT
- **Language**: English (documentation), Spanish OK for personal notes

### DevFlow Plugin
- **Type**: Pure Claude Code slash commands
- **Format**: Markdown files with YAML frontmatter
- **Templates**: Framework-specific configuration examples (Python, TypeScript/Node.js)
- **Dependencies**: GitHub CLI (`gh`), project-specific tools

## Build and Development Commands

### Local Development Setup

```bash
# Clone the repository
git clone https://github.com/docutray/docutray-claude-code-plugins
cd docutray-claude-code-plugins

# Add as local marketplace in Claude Code
/plugin marketplace add .

# Install plugin for testing
/plugin install devflow@local

# Test changes (uninstall and reinstall to refresh)
/plugin uninstall devflow
/plugin install devflow@local
```

### Plugin Development Workflow

1. **Modify plugin files** in `plugins/<plugin-name>/`
2. **Update version** in `plugins/<plugin-name>/.claude-plugin/plugin.json`
3. **Update marketplace** version in `.claude-plugin/marketplace.json` if needed
4. **Test locally** using the steps above
5. **Update CHANGELOG.md** with notable changes

## Plugin Architecture

### Marketplace Configuration

The root `.claude-plugin/marketplace.json` is the central catalog:

```json
{
    "name": "docutray-plugins",
    "description": "...",
    "owner": { "name": "...", "email": "..." },
    "plugins": [
        {
            "name": "plugin-name",
            "source": "./plugins/plugin-name",
            "description": "...",
            "version": "1.0.0",
            "category": "development|research|..."
        }
    ]
}
```

### Plugin Manifest

Each plugin has a `plugin.json` manifest:

```json
{
    "name": "plugin-name",
    "version": "1.0.0",
    "description": "...",
    "author": { "name": "...", "email": "..." },
    "repository": "...",
    "license": "MIT",
    "keywords": ["..."]
}
```

### Slash Commands

Commands are defined in Markdown files with YAML frontmatter:

```markdown
---
description: "Command description"
allowed-tools:
  - Read
  - Bash
  - WebSearch
argument-hints:
  - "<arg1>"
  - "<arg2>"
---

# Command content (Claude prompt)
```

**Special syntax in commands**:
- `$ARGUMENTS` - All arguments passed to command
- `$1`, `$2` - Specific positional arguments
- `!`command`` - Execute bash command and insert output
- `@file` - Reference file content
- `${CLAUDE_PLUGIN_ROOT}` - Plugin installation directory

### Skills

Skills are defined in `SKILL.md` files with frontmatter:

```markdown
---
name: skill-name
description: "Must include trigger terms for auto-activation"
---
```

Skills auto-activate when user queries match trigger terms in the description.

### Agents

Agents are specialized prompts for autonomous tasks, defined in `agents/<agent-name>.md`:

```markdown
---
name: agent-name
description: "When to trigger this agent"
whenToUse: "Detailed trigger conditions"
tools: ["Bash", "Read", ...]
model: sonnet
---
```

## Code Style Guidelines

### Markdown Files
- Use YAML frontmatter for metadata (commands, skills)
- Use ATX-style headers (`#` not `===`)
- Line length: ~100 characters for readability
- Use code blocks with language specifiers

### JSON Files
- 4-space indentation
- Trailing commas allowed (json5-friendly)
- Sort keys alphabetically where logical

## Testing Instructions

### Plugin Integration Testing

```bash
# In Claude Code, test each command
/devflow:feat test-feature --type=feat
/devflow:dev issue#1
/devflow:check
```

### Debugging

Use `claude --debug` to troubleshoot plugin loading issues:

```bash
claude --debug
# Then in Claude Code:
/plugin list
/plugin marketplace list
```

## Security Considerations

### API Keys and Secrets
- **Never commit** API keys to the repository
- Document required secrets in README files, not in code

### File System Access
- Plugins execute with user's permissions
- Commands can execute arbitrary bash commands - review carefully

### Command Allowed Tools
Restrict `allowed-tools` in command frontmatter to minimum required:

```yaml
# Good - minimal permissions
allowed-tools:
  - Read
  - Bash(git status:*)
  - Bash(gh issue:*)

# Avoid - overly permissive
allowed-tools: "*"
```

## Release Process

1. **Update version** in plugin's `plugin.json`
2. **Update version** in root `marketplace.json`
3. **Update CHANGELOG.md** with changes
4. **Test locally** with `/plugin marketplace add .`
5. **Commit changes**: `git commit -am "Release plugin-name vX.Y.Z"`
6. **Push to GitHub**: `git push origin main`
7. **Tag release** (optional): `git tag vX.Y.Z && git push origin vX.Y.Z`

Users update the plugin by reinstalling:
```bash
/plugin uninstall devflow
/plugin install devflow@docutray-plugins
```

## Common Development Tasks

### Adding a New Plugin

1. Create directory: `mkdir plugins/new-plugin`
2. Create manifest: `plugins/new-plugin/.claude-plugin/plugin.json`
3. Add commands: `plugins/new-plugin/commands/command-name.md`
4. Create README: `plugins/new-plugin/README.md`
5. Register in `.claude-plugin/marketplace.json`

### Adding a Slash Command

1. Create file: `plugins/<plugin>/commands/command-name.md`
2. Add YAML frontmatter with description and allowed-tools
3. Write command prompt content
4. Update plugin version in `plugin.json`

### Adding a Skill

1. Create directory: `plugins/<plugin>/skills/<skill-name>/`
2. Create `SKILL.md` with required frontmatter
3. Ensure description includes trigger terms for auto-activation
4. Add supporting files in subdirectory if needed

## Troubleshooting

### Plugin Not Loading
- Check `plugin.json` syntax (valid JSON)
- Verify marketplace.json references correct source path
- Use `claude --debug` for detailed errors

### Command Not Working
- Verify allowed-tools includes required tools
- Check for typos in `$ARGUMENTS` or variable references
- Test bash commands directly in terminal

## References

- [Claude Code Plugins Overview](https://docs.claude.com/en/docs/claude-code/plugins)
- [Plugins Reference](https://docs.claude.com/en/docs/claude-code/plugins-reference)
- [Slash Commands](https://docs.claude.com/en/docs/claude-code/slash-commands)
- [Skills](https://docs.claude.com/en/docs/claude-code/skills)

## Contact

- **Issues**: [GitHub Issues](https://github.com/docutray/docutray-claude-code-plugins/issues)
- **Maintainer**: Roberto Arce (roberto@docutray.com)
- **Organization**: Docutray
