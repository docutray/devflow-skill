---
description: "Implement features based on GitHub issues, creating development branch, following best practices, and generating complete Pull Request"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Task
  - TodoWrite
argument-hints:
  - "issue#<number>"
  - "--branch=custom-name"
  - "--draft"
  - "--auto-tests"
  - "--full-validation"
  - "--worktree"
---

# Development Implementation Command

Command to implement features based on GitHub issues, creating a development branch, following project best practices, and ending with Pull Request generation.

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`
- Remote URL: !`git remote get-url origin`

## Usage

```bash
/dev issue#<number> [--branch=custom-name] [--draft] [--auto-tests] [--full-validation]
```

## Objective

Implement complete features based on existing GitHub issues, following a structured development flow that includes:
- Issue specification download and analysis
- Optional OPSX workflow (spec-driven development with discrete artifacts)
- Development branch creation
- Step-by-step implementation following best practices
- Continuous validation with tests and linting
- Pull Request generation with complete documentation

## Parameters

- `issue#<number>`: Issue number to implement (required)
- `--branch`: Custom name for the branch (optional, auto-generates by default)
- `--draft`: Create PR as draft for incremental review (optional)
- `--auto-tests`: Automatically run tests after each change (optional)
- `--full-validation`: Run complete validation suite at the end (optional)
- `--worktree`: Run in an isolated git worktree for parallel development (optional). See `@${CLAUDE_PLUGIN_ROOT}/templates/worktree-guide.md` for details.

## Instructions for Claude

**IMPORTANT - Complete and structured development flow**

### Implementation Flow

The command has automatic access to git context (see Context section above).

1. **State Verification**: Review git context to detect uncommitted changes
2. **Issue Download**: Get all issue information from GitHub
3. **Specification Analysis**: Parse and structure technical specification
4. **OPSX Planning (if enabled)**: Use `/opsx:new` or `/opsx:ff` to create change artifacts from the issue
5. **Environment Preparation**: Create branch and configure development workspace
6. **Guided Implementation**: Use `/opsx:apply <change>` (if enabled) to develop step by step following the tasks
7. **Continuous Validation**: Run tests and validations during development
8. **Verification & Finalization**: Use `/opsx:verify`, `/opsx:sync`, and `/opsx:archive` (if enabled), then create Pull Request

### Detailed Process

#### 1. Issue Download and Analysis

**Getting Information**
```bash
# Download complete issue information
gh issue view <number> --json title,body,assignees,labels,milestone,state,comments

# Verify issue is open and assigned
# Extract technical specification and task checklist
# Identify affected areas and dependencies
```

**Issue Validation**
- Verify issue exists and is accessible
- Confirm it has complete technical specification
- Validate it includes clear acceptance criteria
- Verify it has implementation checklist

#### 2. OPSX Planning (Optional)

OPSX (OpenSpec fluid workflow) is optional and repo-specific. If the repository uses OpenSpec/OPSX, `/dev` must generate planning artifacts from the issue **before starting implementation**.

**How to detect OPSX**

Treat OPSX as enabled when the repo contains:
- `openspec/config.yaml` (primary indicator for OPSX)
- Or legacy: `openspec/specs/` and/or `openspec/changes/`

Additionally, check if OPSX slash commands are available (installed via OpenSpec CLI with `openspec experimental`).

If the `openspec/` directory exists but the commands are not available, ask the user to install OpenSpec (see `/devflow-setup`).

**What to do when enabled**

Use OPSX slash commands to create planning artifacts from the GitHub issue:

**Option A: Fast-forward (recommended for well-defined issues)**
```
/opsx:ff issue#<number>
```
This creates all planning artifacts at once: proposal → specs → design → tasks

**Option B: Incremental (for exploratory work)**
```
/opsx:new issue#<number>
```
Then use `/opsx:continue <change>` to create artifacts one at a time based on dependency readiness.

**Option C: Exploration first**
```
/opsx:explore issue#<number>
```
Brainstorm without structured output, then proceed with `/opsx:new`.

**Artifact structure (spec-driven schema)**

OPSX creates discrete artifacts with dependencies:
1. **proposal** — Change proposal (root, no dependencies)
2. **specs** — Specifications (requires proposal)
3. **design** — Technical design (requires proposal)
4. **tasks** — Implementation tasks (requires specs and design)

Change folder structure:
```
openspec/changes/<change>/
├── .openspec.yaml        # Change metadata
├── proposal.md           # Change proposal
├── specs/                # Delta specs (merged on archive)
│   └── .../spec.md
├── design.md             # Technical design (optional)
└── tasks.md              # Implementation checklist
```

**Minimum expected output**

- A proposal artifact created in the change folder
- The proposal references the GitHub issue (`#<number>`) and captures intent
- Tasks.md built from issue checklist and acceptance criteria (if using `/opsx:ff`)

#### 2. Development Environment Preparation

**Git State Verification**

Git context is already automatically available. If there are uncommitted changes (detected in `git status`), ask user what to do:
- **Stash**: `git stash save "WIP before /dev issue#X"`
- **Commit**: Create commit with current changes
- **Discard**: `git reset --hard` (with confirmation)

**Branch Creation**

Determine branch name based on issue:
```bash
BRANCH_NAME="feat/issue-<number>-<title-slug>"
```

Determine base branch:
- If issue is part of an epic: `BASE_BRANCH="epic/<epic-name>"`
- Otherwise: `BASE_BRANCH="main"`

**Worktree Mode** (if `--worktree` is used):

Read `@${CLAUDE_PLUGIN_ROOT}/templates/worktree-guide.md` for full worktree procedures.

1. **Detect existing worktree**: Check if CWD is already inside `.claude/worktrees/` using `git rev-parse --show-toplevel`. If yes, skip worktree creation and work in-place.

2. **Ensure `.gitignore` includes worktrees**:
```bash
grep -q "\.claude/worktrees" .gitignore 2>/dev/null || echo -e "\n# Claude Code worktrees\n.claude/worktrees/" >> .gitignore
```

3. **Create worktree**:
```bash
git fetch origin
WORKTREE_NAME=$(echo "$BRANCH_NAME" | tr '/' '-')
WORKTREE_DIR=".claude/worktrees/$WORKTREE_NAME"
git worktree add "$WORKTREE_DIR" -b $BRANCH_NAME origin/$BASE_BRANCH
```

4. **All subsequent bash commands must run inside the worktree** (shell state does not persist):
```bash
cd "$WORKTREE_DIR" && <command>
```

5. **Push branch from worktree**:
```bash
cd "$WORKTREE_DIR" && git push -u origin $BRANCH_NAME
```

6. **Install dependencies inside worktree** (read from `.claude/details/commands/dev.md`).

**Standard Mode** (default, without `--worktree`):
```bash
# Ensure we're on base branch updated
git checkout $BASE_BRANCH
git pull origin $BASE_BRANCH

# Create new branch for development
git checkout -b $BRANCH_NAME
git push -u origin $BRANCH_NAME
```

**Workspace Configuration**

Read from `.claude/details/commands/dev.md` for project-specific setup:
```bash
# Example for Node.js projects:
npm ci
# Generate types if necessary
# Verify environment is clean
```

**Initial Validation**
```bash
# Run quick validation to ensure clean starting point
/check --fast
```

#### 3. Step-by-Step Implementation

**Specification Analysis**
- Extract task checklist from issue
- Prioritize tasks by dependencies
- Identify optimal implementation order
- Plan intermediate validations

**OPSX-Guided Implementation (if enabled)**

When OPSX is enabled, use the `/opsx:apply` slash command to guide the implementation:

```
/opsx:apply <change-name>
```

This command will:
1. Read the proposal, specs, design, and tasks from the change folder
2. Guide step-by-step implementation following the tasks.md checklist
3. Update task status as items are completed
4. Maintain consistency between implementation and specs

**Verify implementation against specs:**
```
/opsx:verify <change-name>
```
Use this periodically to validate that implementation matches the specifications.

**Incremental Development**
- Implement one task at a time from checklist
- Run relevant tests after each change
- Make frequent commits with descriptive messages
- Validate each step doesn't break existing functionality

**Implementation Patterns**
- Follow existing project conventions
- Use established libraries and utilities
- Respect project architecture
- Implement appropriate error handling
- Consider security and performance aspects

#### 4. Continuous Validation

**Tests During Development**

Read from `.claude/details/commands/dev.md` for project-specific test commands:
```bash
# Example commands (project-specific):
npm run test
# or
pytest tests/
# or
./gradlew test

# Quick validation during development
/check --fast

# Complete validation at key points
/check
```

**Acceptance Criteria Validation**
- Verify each acceptance criterion from issue
- Test edge cases and error handling
- Validate integration with other components
- Confirm no regressions introduced

#### 5. Finalization and Pull Request

**Final Validation**
```bash
# Complete validation suite using optimized command
/check --fast    # For quick validation (without build)
/check          # For complete validation including build

# Verify test coverage if necessary
# (project-specific command from details file)
```

**OPSX Verification and Archiving Gate (if enabled)**

If OPSX is enabled (based on the presence of `openspec/config.yaml` or `openspec/`), ensure verification and archiving **before creating the PR**.

**Step 1: Verify implementation**
```
/opsx:verify <change-name>
```
Validates that implementation matches the specifications.

**Step 2: Preview spec sync**
```
/opsx:sync <change-name>
```
Preview how delta specs will merge into the main `openspec/specs/` directory.

**Step 3: Archive the change**
```
/opsx:archive <change-name>
```

Where `<change-name>` is the change folder created during planning (e.g., `issue-<number>-<title-slug>`).

This command will:
1. Validate the change folder is complete
2. Merge delta specs from `openspec/changes/<change>/specs/` to `openspec/specs/`
3. Archive the proposal and update status
4. Clean up the change folder

The PR must reference:
- The proposal path (draft location) and/or
- The archived proposal path (final location), depending on team convention

**Pull Request Preparation**
- Generate description based on implemented issue
- Include summary of changes made
- Document testing strategy used
- Create review checklist

**Creating Pull Request**

Determine base branch:
- If part of epic: base = epic branch
- Otherwise: base = main

```bash
gh pr create \
  --title "feat: [Title based on issue]" \
  --body "$(cat <<'EOF'
## 🔗 Related Issue
Closes #<number>

## 📄 OPSX Change (if enabled)
- **Change folder**: `openspec/changes/<change-name>/`
- **Proposal**: [Link to proposal.md]
- **Specs**: [Link to archived specs]

## 📋 Changes Summary
[Description of implemented changes]

## ✅ Completed Acceptance Criteria
[List of verified criteria from issue]

## 🧪 Testing
[Description of testing performed]

## 📝 Notes for Reviewers
[Important information for review]

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)" \
  --base <base-branch> \
  --head $BRANCH_NAME
```

### Technical Considerations

#### Project Compatibility
- Identify affected areas automatically
- Run specific commands per area when necessary
- Verify interdependencies
- Validate changes don't affect other areas

#### Best Practices Adherence
- Frequent commits with descriptive messages following conventions
- Incremental implementation following issue checklist
- Continuous validation to avoid regressions
- Documentation of complex changes

#### Error Handling and Contingencies
- Automatic rollback if validations fail
- Checkpoint commits for recovery
- Documentation of problems found during implementation
- Escalation to user when decisions needed

### Integration with Other Commands

#### Complete Development Flow
1. `/feat` → Create technical specification and issue
2. `/dev issue#X` → Implement functionality (uses `/check` for validations)
3. `/check` → Validate implementation quality
4. `/review-pr pr#Y` → Review and approve Pull Request

#### Handoff Between Commands
- `/dev` uses specification generated by `/feat`
- `/review-pr` can reference original issue for context
- Shared information through GitHub metadata

### Common Use Cases

#### Complete Feature Implementation
```bash
/dev issue#123
# Implements full issue functionality following specification
```

#### Development with Continuous Validation
```bash
/dev issue#123 --auto-tests
# Automatically runs tests after each significant change
```

#### Incremental Development with Draft PR
```bash
/dev issue#123 --draft
# Creates PR as draft for incremental progress review
```

#### Exhaustive Validation
```bash
/dev issue#123 --full-validation
# Runs all possible validations at the end
```

#### Parallel Development with Worktrees
```bash
# Terminal 1: Implement feature in isolated worktree
/dev issue#123 --worktree

# Terminal 2: Implement another feature simultaneously
/dev issue#456 --worktree
```

### User Output

**Process Start**
```
🚀 STARTING DEVELOPMENT - Issue #<number>

📋 Issue: [Issue Title]
🎯 Objective: [Issue Summary]
🏗️ Affected areas: [List of areas]

📝 Loaded specification:
- Acceptance criteria: [X] items
- Implementation tasks: [Y] items
- Testing strategy: [Description]

🌿 Creating branch: feat/issue-<number>-<slug>

Proceed with implementation? (Y/n)
```

**During Development**
```
🔧 Implementing: [Task Name]
✅ Tests passing: [X/Y]
📊 Progress: [X/Y] tasks completed
⏱️ Estimated remaining time: [estimate]
```

**Finalization**
```
✅ IMPLEMENTATION COMPLETED - Issue #<number>

📊 Summary:
- Modified files: [quantity]
- Tests added/modified: [quantity]
- Commits made: [quantity]
- Acceptance criteria met: [X/Y]

🔍 Final validations (/check):
- ✅ Linting: No errors
- ✅ Type checking: No errors
- ✅ Tests: [X] passing, [Y] added
- ✅ Build: Successful
- ⏱️ Total time: [X]s (parallel)

🚀 Pull Request created: #<pr-number>
📋 Issue will close automatically on merge

🎯 Next step: /review-pr <pr-number> for technical review
```

**Worktree Mode Finalization** (if `--worktree` was used):
```
🌿 Worktree Info:
   Location: .claude/worktrees/<name>
   Branch: <branch-name>

📋 After PR is merged, clean up:
   git worktree remove .claude/worktrees/<name>

📋 List active worktrees:
   git worktree list
```

## Project Customization

**IMPORTANT**: Each project must customize development details in:
`.claude/details/commands/dev.md`

This file should include:
- Dependency installation commands
- Project-specific test commands
- Build and validation commands
- Environment setup procedures
- Framework-specific considerations
- Code organization patterns

**Projects must configure this file during `/devflow-setup`**

## Reference

For specific procedures, troubleshooting, and advanced configurations, consult:
`.claude/details/commands/dev.md`
