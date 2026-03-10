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
| [devflow](./plugins/devflow/) | Complete agile development workflow with GitHub integration | 1.2.0 |
| [rag-research](./plugins/rag-research/) | RAG-based document indexing and semantic search with project-local database support | 1.1.1 |

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

## Plugin: RAG Research

RAG-based reference document management for Claude Code. Index documents (PDF, Markdown, Text) and search them semantically using Qdrant + FastEmbed for efficient local vector storage and retrieval.

### Quick Start

```bash
# Install
/plugin install rag-research@docutray-plugins

# Setup dependencies (first time only)
cd ~/.claude/plugins/marketplaces/docutray-plugins/plugins/rag-research
uv sync

# Use commands
/rag-research:add-doc ./docs/manual.pdf    # Index a document
/rag-research:list                          # List indexed documents
/rag-research:research "your topic"         # Semantic search
```

### Commands

| Command | Description |
|---------|-------------|
| `/rag-research:add-doc` | Index a document (PDF, Markdown, Text, JSON) |
| `/rag-research:list` | List all indexed documents with filtering |
| `/rag-research:research` | Semantic search across indexed documents |

### Features

- **Document Indexing**: PDF, Markdown, Text, JSON support
- **Semantic Search**: FastEmbed embeddings + Qdrant vector store
- **Local Storage**: No external servers required
- **PDF OCR**: Mistral AI integration for scanned documents
- **Deep Research Agent**: Autonomous comprehensive topic research

### Configuration

Set `MISTRAL_API_KEY` in `.env` for PDF OCR support (optional - falls back to pypdf).

[**View Full Documentation**](./plugins/rag-research/README.md)

---

## Repository Structure

```
docutray-claude-code-plugins/
├── .claude-plugin/
│   └── marketplace.json      # Marketplace catalog
├── .kimi/                    # Kimi CLI Flow Skills
│   └── skills/
│       └── devflow/          # DevFlow flow skills
│           ├── feat/
│           ├── dev/
│           ├── check/
│           ├── review-pr/
│           ├── research/
│           └── epic/
├── plugins/
│   ├── devflow/              # DevFlow plugin (Claude Code)
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── commands/         # Slash commands
│   │   ├── templates/
│   │   └── README.md
│   └── rag-research/         # RAG Research plugin
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── commands/
│       ├── skills/
│       ├── agents/
│       ├── src/
│       └── README.md
├── install-kimi-flows.sh     # Installer for Kimi Flow Skills
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

# Install plugins
/plugin install devflow@docutray-plugins
/plugin install rag-research@docutray-plugins
```

---

## 🚀 Kimi CLI Support (Flow Skills)

This repository also includes **Flow Skills** for [Kimi CLI](https://moonshotai.github.io/kimi-cli/), providing the same DevFlow workflows as automated multi-step processes.

### What are Flow Skills?

Flow Skills are a special skill type in Kimi CLI that define multi-step automated workflows using flow diagrams. Unlike Claude's slash commands which execute in one step, Flow Skills guide the Agent through complex processes with decision points and loops.

### Available Flow Skills

| Flow Skill | Description | Kimi Command |
|------------|-------------|--------------|
| `devflow-feat` | Create feature specifications and GitHub issues | `/flow:devflow-feat` |
| `devflow-dev` | Implement features from GitHub issues | `/flow:devflow-dev` |
| `devflow-check` | Execute parallel validations | `/flow:devflow-check` |
| `devflow-review-pr` | Review Pull Requests | `/flow:devflow-review-pr` |
| `devflow-research` | Research topics before planning | `/flow:devflow-research` |
| `devflow-epic` | Plan major initiatives | `/flow:devflow-epic` |

### Installation for Kimi CLI

```bash
# Clone this repository
git clone https://github.com/docutray/docutray-claude-code-plugins
cd docutray-claude-code-plugins

# Install flow skills (copies to ~/.config/agents/skills/)
./install-kimi-flows.sh

# Or install with symlinks for development (auto-updates)
./install-kimi-flows.sh --symlink
```

### Quick Start with Kimi

```bash
# Start Kimi
kimi

# Create a feature
/flow:devflow-feat

# Implement it
/flow:devflow-dev issue#123

# Validate
/flow:devflow-check

# Review PR
/flow:devflow-review-pr 45
```

### Claude vs Kimi Comparison

| Feature | Claude Code | Kimi CLI |
|---------|-------------|----------|
| **Format** | Slash Commands | Flow Skills |
| **Execution** | Single-step | Multi-step with decisions |
| **DevFlow** | `/devflow:feat` | `/flow:devflow-feat` |
| **Automation** | Manual steps | Guided workflow |
| **Diagrams** | N/A | Visual Mermaid flows |

The Flow Skills are located in `.kimi/skills/` and do not interfere with Claude Code plugins.

[**View Kimi Flow Skills Documentation**](./.kimi/README.md)

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
