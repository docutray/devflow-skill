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
