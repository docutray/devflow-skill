# AGENTS.md - Docutray DevFlow Skill

This file provides essential context for AI coding agents working with the Docutray DevFlow Skill repository.

## Project Overview

This is a **portable Agent Skill repository** maintained by the Docutray organization. It contains the DevFlow skill for software development workflows plus Claude Code slash command wrappers for compatibility.

**Important**: This is NOT a traditional application codebase. The canonical behavior lives in `skills/devflow/`; Claude Code plugin files are distribution and compatibility adapters.

### Current Plugins

| Skill | Version | Description | Category |
|--------|---------|-------------|----------|
| `devflow` | 2.5.0 | Complete agile development workflow with GitHub integration | development |

## Repository Structure

```
devflow-skill/
├── .claude-plugin/
│   └── marketplace.json          # Central marketplace catalog
├── skills/
│   └── devflow/                  # Canonical Agent Skill
│       ├── SKILL.md
│       ├── references/
│       └── assets/
│           ├── templates/        # .devflow/ config examples
│           └── scripts/          # helpers setup copies into consumer repos
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
- **Format**: `SKILL.md` with YAML frontmatter plus Markdown references. Keep `SKILL.md` concise and put detailed workflows and procedures in `skills/devflow/references/`, linked one level deep from `SKILL.md`; `assets/` holds templates and scripts, never procedures.
- **Templates**: Framework-specific configuration examples under `skills/devflow/assets/templates/`
- **Scripts**: POSIX `sh` helpers under `skills/devflow/assets/scripts/`, such as the OpenSpec gate `opsx-validate.sh`. Setup copies them into the consumer repository's `.devflow/scripts/`, since a check command cannot know where the skill is installed. Test them under `dash`.
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
3. **Update version** in all four places that carry it: `skills/devflow/SKILL.md`,
   `.claude-plugin/marketplace.json`, `README.md` (`Current version:`), and the plugin table
   in this file
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
            "version": "<current version>",
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
  - Bash(git status:*)
  - WebSearch
argument-hint: "<arg1> [--flag]"
---

# Command content (Claude prompt)
```

`argument-hint` is singular and takes one string: required arguments bare or in `<>`, optional ones in `[]`. Claude Code silently drops unknown frontmatter keys, so a misspelled or pluralized key shows no hint and raises no error.

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

Skills auto-activate when user queries match trigger terms in the description. The description is the only trigger surface in clients without slash commands, so it must lead with natural-language intent rather than command names.

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

### Validation

Every validator must pass before a release:

```bash
jq empty .claude-plugin/marketplace.json
claude plugin validate --strict .
uvx --from skills-ref agentskills validate ./skills/devflow
uvx --with pyyaml python ~/.codex/skills/.system/skill-creator/scripts/quick_validate.py ./skills/devflow
```

The Codex skill-creator validator accepts only `name`, `description`, `license`, `allowed-tools`, and `metadata` in the frontmatter, so environment requirements live in the `SKILL.md` body rather than in a `compatibility` field. See `docs/skills-best-practices.md` for the full toolchain.

### Integration Testing

Test both clients. Codex is a first-class target, not an afterthought.

```bash
npx skills add . --skill devflow
```

In Codex, verify the skill auto-activates from natural language alone, since Codex has no slash commands:

```text
Use DevFlow to create a GitHub issue for a test feature.
Use DevFlow to implement issue #1.
Use DevFlow to run validation checks.
```

In Claude Code, verify the same phrasing works, then verify the optional wrappers:

```bash
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
`allowed-tools` pre-approves tools; it does not restrict them. Every tool stays callable while a command runs, and the listed ones simply skip the permission prompt. Grant only what the workflow should run without asking, and scope Bash grants to command patterns:

```yaml
# Good - pre-approves read-only inspection; anything else still prompts
allowed-tools:
  - Read
  - Bash(git status:*)
  - Bash(gh pr view:*)

# Avoid - pre-approves every shell command, including scripts from a fork's PR
allowed-tools:
  - Bash
```

A pattern such as `Bash(git log:*)` is a prefix match and approves every flag that follows it. Some read-looking commands take flags that execute code or write files (`git fetch --upload-pack=<cmd>`, `git log --output=<file>`, `git diff --output=<file>`, `git branch -D`), so pre-approve a command by prefix only when none of its flags can do that, such as `git status`, `gh pr view`, `gh pr diff`, `gh issue view`, or `gh label list`. For a command that has such flags, grant the exact invocation without `:*`, such as `Bash(git branch --show-current)` or `Bash(git remote -v)`, which approves nothing else.

Never grant bare `Bash` or `Edit` to a workflow that may handle untrusted content, such as PR review, which can check out a pull request from a fork: running the PR's tests or applying fixes should go through the user's normal permission prompts. `dev` and `check` keep bare `Bash` because they run the project's own commands on request; that is only as trustworthy as the checked-out branch, so after checking out a branch from a fork, run them with prompts on. To actually forbid a tool, use `disallowed-tools`.

## Release Process

1. **Update version** in `skills/devflow/SKILL.md`
2. **Update version** in root `marketplace.json`, `README.md`, and the plugin table above
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
2. Add YAML frontmatter with `description`, a scoped `allowed-tools` pre-approval list, and a single-string `argument-hint`
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
- `allowed-tools` only removes permission prompts; a tool missing from it still works after the user approves it
- Check that the hint key is `argument-hint` (singular, one string); misspelled keys are ignored silently
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
