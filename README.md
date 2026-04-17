# Docutray Plugins Marketplace

A collection of [Claude Code](https://docs.claude.com/en/docs/claude-code/overview) plugins maintained by the Docutray organization.

## Installation

### Add the Marketplace

```bash
/plugin marketplace add docutray/docutray-claude-code-plugins
```

### Install Plugins

```bash
/plugin install <plugin-name>@docutray-plugins
```

Or use the interactive menu:
```bash
/plugin
# Select "Browse Plugins" → choose from docutray-plugins
```

## Available Plugins

| Plugin | Description | Version |
|--------|-------------|---------|
| [devflow](./plugins/devflow/) | Complete agile development workflow with GitHub integration | 1.3.0 |

---

## Plugin: DevFlow

A comprehensive set of slash commands that implement a complete agile development workflow based on GitHub and best practices.

### Quick Start

```bash
# Install
/plugin install devflow@docutray-plugins

# Configure for your project
/devflow:devflow-setup

# Standard workflow
/devflow:feat feature-name     # Create specification & GitHub issue
/devflow:dev issue#123         # Implement feature
/devflow:check                 # Validate quality
/devflow:review-pr 45          # Review PR
```

### Commands

| Command | Description |
|---------|-------------|
| `/devflow:devflow-setup` | Configure DevFlow for your project |
| `/devflow:feat` | Create feature specifications and GitHub issues |
| `/devflow:dev` | Implement features from GitHub issues |
| `/devflow:check` | Run parallel validations (tests, lint, types, build) |
| `/devflow:review-pr` | Perform comprehensive PR reviews |
| `/devflow:research` | Research topics before planning |
| `/devflow:epic` | Plan major initiatives with multiple phases |

### Framework Support

TypeScript/Node.js, Python, Go, Ruby, Java, Rust, and more.

[**View Full Documentation**](./plugins/devflow/README.md)

---

## Repository Structure

```
docutray-claude-code-plugins/
├── .claude-plugin/
│   └── marketplace.json      # Marketplace catalog
├── plugins/
│   └── devflow/              # DevFlow plugin (Claude Code)
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── commands/         # Slash commands
│       ├── templates/
│       └── README.md
├── README.md                 # This file
└── CLAUDE.md
```

## Local Development

```bash
# Clone the repository
git clone https://github.com/docutray/docutray-claude-code-plugins
cd docutray-claude-code-plugins

# Add as local marketplace
/plugin marketplace add .

# Install plugin
/plugin install devflow@docutray-plugins
```

---

## Adding New Plugins

1. Create a new directory under `plugins/`:
   ```
   plugins/new-plugin/
   ├── .claude-plugin/
   │   └── plugin.json
   ├── commands/
   └── README.md
   ```

2. Add the plugin to `marketplace.json`:
   ```json
   {
     "plugins": [
       { "name": "new-plugin", "source": "./plugins/new-plugin", ... }
     ]
   }
   ```

3. Document the plugin in its own `README.md`

## Official Documentation

- [Plugins Overview](https://docs.claude.com/en/docs/claude-code/plugins)
- [Plugins Reference](https://docs.claude.com/en/docs/claude-code/plugins-reference)
- [Slash Commands](https://docs.claude.com/en/docs/claude-code/slash-commands)
- [Skills](https://docs.claude.com/en/docs/claude-code/skills)

## License

MIT

## Support

- **Issues**: [GitHub Issues](https://github.com/docutray/docutray-claude-code-plugins/issues)
- **Contact**: Roberto Arce (roberto@docutray.com)

---

Built with [Claude Code](https://docs.claude.com/en/docs/claude-code/overview) by Docutray
