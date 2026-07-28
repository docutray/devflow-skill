# Git Worktree Guide for DevFlow

Reference document for worktree operations in DevFlow commands. Read this when a command uses the `--worktree` flag.

## Path Convention

Worktrees are created under `.claude/worktrees/` in the repository root. Branch names are sanitized (slashes → hyphens) for directory names:

| Branch | Worktree Directory |
|--------|-------------------|
| `feat/issue-123-auth` | `.claude/worktrees/feat-issue-123-auth` |
| `epic/oauth-integration` | `.claude/worktrees/epic-oauth-integration` |
| PR #45 review | `.claude/worktrees/review-pr-45` |

## Prerequisite

Ensure `.claude/worktrees/` is in the project's `.gitignore`:
```bash
# Check if already ignored
grep -q "\.claude/worktrees" .gitignore 2>/dev/null || echo -e "\n# Claude Code worktrees\n.claude/worktrees/" >> .gitignore
```

## Worktree Detection

Before creating a new worktree, check if already inside one:
```bash
WORKTREE_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [[ "$WORKTREE_ROOT" == *".claude/worktrees/"* ]]; then
  echo "Already in worktree: $WORKTREE_ROOT"
  # Skip worktree creation, work in-place
fi
```

## Creating a Worktree

```bash
# Fetch latest remote state
git fetch origin

# Create worktree with new branch based on a remote branch
WORKTREE_DIR=".claude/worktrees/<sanitized-branch-name>"
git worktree add "$WORKTREE_DIR" -b <branch-name> origin/<base-branch>

# For reviewing an existing remote branch (no new branch):
git worktree add "$WORKTREE_DIR" <existing-branch>
```

## Working Inside a Worktree

**CRITICAL**: Shell state does not persist between Bash tool calls. Every bash command that needs to run inside the worktree must explicitly `cd` into it:

```bash
# Every bash command must start with:
cd "$WORKTREE_DIR" && <command>

# Examples:
cd ".claude/worktrees/feat-issue-123-auth" && npm ci
cd ".claude/worktrees/feat-issue-123-auth" && npm run test
cd ".claude/worktrees/feat-issue-123-auth" && git add -A && git commit -m "feat: add auth"
```

## Post-Creation Setup

After creating a worktree, install dependencies. Read from `.claude/details/commands/dev.md` for project-specific commands. Common patterns:

```bash
cd "$WORKTREE_DIR" && npm ci          # Node.js
cd "$WORKTREE_DIR" && uv sync         # Python (uv)
cd "$WORKTREE_DIR" && pip install -e . # Python (pip)
cd "$WORKTREE_DIR" && go mod download  # Go
```

## Cleanup

After a PR is merged or work is complete:

```bash
# List all active worktrees
git worktree list

# Remove a specific worktree (must be clean)
git worktree remove .claude/worktrees/<name>

# Force removal if needed (discards uncommitted changes)
git worktree remove --force .claude/worktrees/<name>

# Prune stale worktree entries
git worktree prune
```

## Parallel Development Example

Run each stream in its own terminal and worktree. Ask for the workflow in natural language, which works in Codex and Claude Code alike:

```text
# Terminal 1: Implement a feature
Use DevFlow to implement issue #123 in an isolated worktree.

# Terminal 2: Review a PR (simultaneously)
Use DevFlow to review PR #45 in an isolated worktree.

# Terminal 3: Implement another feature (simultaneously)
Use DevFlow to implement issue #456 in an isolated worktree.
```

In Claude Code the optional slash commands are equivalent shortcuts: `/devflow:dev issue#123 --worktree`, `/devflow:review-pr 45 --worktree`.

## Troubleshooting

- **"branch already checked out"**: A branch can only be checked out in one worktree at a time. Use `git worktree list` to find which worktree has it.
- **"not a valid directory"**: Run `git worktree prune` to clean stale entries.
- **Dependencies missing**: Each worktree needs its own dependency installation. Run the project's install command inside the worktree.
- **`.env` not found**: Copy `.env` from the main worktree: `cp .env .claude/worktrees/<name>/.env`
