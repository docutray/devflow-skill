# AGENTS.md - Docutray DevFlow Skill

This file provides essential context for AI coding agents working with the Docutray DevFlow Skill repository.

## Project Overview

This is a **portable Agent Skill repository** maintained by the Docutray organization. It contains the DevFlow skill for software development workflows plus Claude Code slash command wrappers for compatibility.

**Important**: This is NOT a traditional application codebase. The canonical behavior lives in `skills/devflow/`; Claude Code plugin files are distribution and compatibility adapters.

### Current Plugins

| Skill | Version | Description | Category |
|--------|---------|-------------|----------|
| `devflow` | 2.0.0 | Complete agile development workflow with GitHub integration | development |

## Repository Structure

```
devflow-skill/
├── .claude-plugin/
│   └── marketplace.json          # Central marketplace catalog
├── skills/
│   └── devflow/                  # Canonical Agent Skill
│       ├── SKILL.md
│       ├── references/
│       └── assets/templates/
├── commands/                     # Claude Code slash command wrappers
├── README.md                     # Skill and marketplace documentation
├── CLAUDE.md                     # Claude Code guidance
├── CHANGELOG.md                  # Version history
└── AGENTS.md                     # This file
```

## Technology Stack

### Repository Level
- **Version Control**: Git
- **License**: MIT
- **Language**: English (documentation), Spanish OK for personal notes

### DevFlow Skill
- **Type**: Agent Skill with Claude Code command wrappers
- **Format**: `SKILL.md` with YAML frontmatter plus Markdown references
- **Templates**: Framework-specific configuration examples under `skills/devflow/assets/templates/`
- **Dependencies**: GitHub CLI (`gh`), project-specific tools

## Build and Development Commands

### Local Development Setup

```bash
# Clone the repository
git clone https://github.com/docutray/devflow-skill
cd devflow-skill

# Add as local marketplace in Claude Code
/plugin marketplace add .

# Install plugin for testing
/plugin install devflow@local

# Test changes (uninstall and reinstall to refresh)
/plugin uninstall devflow
/plugin install devflow@local
```

```bash
# Install locally through skills CLI
npx skills add . --skill devflow
```

### Skill Development Workflow

1. **Modify canonical skill files** in `skills/devflow/`
2. **Keep wrappers thin** in `commands/`
3. **Update version** in `skills/devflow/SKILL.md` and `.claude-plugin/marketplace.json`
4. **Test locally** using the steps above
5. **Update CHANGELOG.md** with notable changes

## Plugin Architecture

### Marketplace Configuration

The root `.claude-plugin/marketplace.json` is the central catalog:

```json
{
    "name": "docutray-skills",
    "description": "...",
    "owner": { "name": "...", "email": "..." },
    "plugins": [
        {
            "name": "plugin-name",
            "source": "./",
            "description": "...",
            "version": "2.0.0",
            "category": "development",
            "strict": false,
            "skills": ["./skills/devflow"]
        }
    ]
}
```

### Plugin Manifest

Version 2 does not use per-plugin `plugin.json`. `.claude-plugin/marketplace.json` is the distribution manifest:

```json
{
    "name": "docutray-skills",
    "plugins": [
        {
            "name": "devflow",
            "source": "./",
            "version": "2.0.0",
            "skills": ["./skills/devflow"]
        }
    ]
}
```

### Slash Commands

Claude Code wrapper commands are defined in root `commands/` with YAML frontmatter:

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

Keep command bodies as thin wrappers that read `@${CLAUDE_PLUGIN_ROOT}/skills/devflow/SKILL.md` and the relevant reference file. Claude Code exposes these as `/devflow:<command-file-name>`, for example `commands/dev.md` becomes `/devflow:dev`.

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

### Integration Testing

```bash
# Agent Skills
npx skills add . --skill devflow

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

1. **Update version** in `skills/devflow/SKILL.md`
2. **Update version** in root `marketplace.json`
3. **Update CHANGELOG.md** with changes
4. **Test locally** with `npx skills add . --skill devflow` and `/plugin marketplace add .`
5. **Commit changes**: `git commit -am "Release devflow vX.Y.Z"`
6. **Push to GitHub**: `git push origin main`
7. **Tag release** (optional): `git tag vX.Y.Z && git push origin vX.Y.Z`

Users update the plugin by reinstalling:
```bash
npx skills add https://github.com/docutray/devflow-skill --skill devflow
/plugin uninstall devflow
/plugin install devflow@docutray-skills
```

## Common Development Tasks

### Adding a New Workflow

1. Add the detailed workflow under `skills/devflow/references/<workflow>.md`
2. Link it from `skills/devflow/SKILL.md` with clear activation guidance
3. Add a root `commands/<workflow>.md` wrapper only if Claude Code slash command UX is needed
4. Document the command as `/devflow:<command-file-name>`

### Adding a Slash Command

1. Create file: `commands/command-name.md`
2. Add YAML frontmatter with description and allowed-tools
3. Delegate command behavior to `skills/devflow/SKILL.md` and a reference file
4. Update versions and changelog

### Adding a Skill

1. Create directory: `skills/<skill-name>/`
2. Create `SKILL.md` with required frontmatter
3. Ensure description includes trigger terms for auto-activation
4. Add supporting files in subdirectory if needed

## Troubleshooting

### Plugin Not Loading
- Check `marketplace.json` syntax (valid JSON)
- Verify marketplace.json references `source: "./"` and `skills: ["./skills/devflow"]`
- Use `claude --debug` for detailed errors

### Command Not Working
- Verify allowed-tools includes required tools
- Check for typos in `$ARGUMENTS` or variable references
- Test bash commands directly in terminal

## References

- [Claude Code Plugins Overview](https://docs.claude.com/en/docs/claude-code/plugins)
- [Plugins Reference](https://docs.claude.com/en/docs/claude-code/plugins-reference)
- [Slash Commands](https://docs.claude.com/en/docs/claude-code/slash-commands)
- [Agent Skills Specification](https://agentskills.io/specification)
- [skills.sh Documentation](https://skills.sh/docs)

## Contact

- **Issues**: [GitHub Issues](https://github.com/docutray/devflow-skill/issues)
- **Maintainer**: Roberto Arce (roberto@docutray.com)
- **Organization**: Docutray
