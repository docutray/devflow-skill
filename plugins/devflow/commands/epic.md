---
description: "Create epic issues for major development initiatives with multiple phases, related issues, and dedicated development branch"
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Bash(git status:*)
  - Bash(git diff:*)
  - Bash(git branch:*)
  - Bash(git log:*)
  - Bash(git remote:*)
  - Bash(gh label:*)
  - Bash(gh issue:*)
  - WebSearch
  - Task
argument-hints:
  - "<epic-name>"
  - "--priority=low"
  - "--priority=medium"
  - "--priority=high"
  - "--priority=critical"
  - "--target-version=X.Y.Z"
  - "--worktree"
---

# Epic Creation Command

Command to create epic issues for major development initiatives that span multiple phases and require multiple related issues.

## Context

- Current git status: !`git status`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`
- Remote URL: !`git remote get-url origin`
- GitHub labels: !`gh label list --json name,description,color`

## Usage

```bash
/epic <epic-name> [--priority=low|medium|high|critical] [--target-version=X.Y.Z]
```

## Objective

Create comprehensive epic planning for major development initiatives including:
- Main epic issue in GitHub with detailed roadmap
- Breakdown into multiple feature/task issues
- Dedicated epic development branch
- Phase planning and dependencies
- Success criteria and milestones
- Integration strategy

## Parameters

- `<epic-name>`: Name of the epic in kebab-case
- `--priority`: Epic priority level (default: `high`)
- `--target-version`: Target version for completion (optional)
- `--worktree`: Create epic branch in an isolated git worktree (optional). See `@${CLAUDE_PLUGIN_ROOT}/templates/worktree-guide.md` for details.

## Instructions for Claude

**IMPORTANT - Structured epic planning process**

### Epic Flow

The command has automatic access to git context and GitHub labels (see Context section above).

1. **Immediately**: Request high-level description of the epic from user
2. **Intelligent analysis**: Infer scope, impact, and breakdown automatically
3. **Specific questions**: Only ask critical questions if necessary:
   - Timeline constraints
   - Resource availability
   - Critical dependencies
   - Compliance requirements
4. **Load details**: Read `.claude/details/commands/epic.md` for complete process and templates
5. **Verify GitHub connectivity**: Check authentication in background
6. **Analyze codebase**: Review current architecture
7. **Generate epic specification**: Create comprehensive epic plan
8. **Create epic branch**: Set up dedicated development branch
9. **Mandatory review**: Present plan to user for approval
10. **Label management**: Verify and create necessary labels
11. **Create epic issue**: Create main epic issue in GitHub
12. **Create sub-issues**: Generate related feature/task issues
13. **Link issues**: Connect sub-issues to epic
14. **Flow information**: Guide user on next steps

### Detailed Process

#### 1. Epic Understanding

Immediately ask user for epic description:
```
Describe the major initiative you want to plan. Include:
- What problem does it solve?
- What are the main capabilities needed?
- Are there specific constraints or requirements?
```

#### 2. Intelligent Analysis

Based on user description, automatically determine:
- **Scope**: Affected areas of the codebase
- **Phases**: Logical breakdown of work
- **Dependencies**: Technical and organizational
- **Timeline**: Rough estimation based on complexity
- **Risks**: Potential challenges and mitigation

#### 3. Epic Structure Generation

Create comprehensive epic specification including:

**Epic Overview**:
- Clear description and motivation
- Business value and impact
- Success criteria
- Target completion timeframe

**Phase Breakdown**:
- Phase 1: Foundation work
- Phase 2: Core implementation
- Phase 3: Integration and polish
- Phase 4: Testing and documentation

**Related Issues**:
Generate list of specific issues that compose the epic:
- Each issue should be independent and deliverable
- Issues should follow logical dependency order
- Each issue needs clear acceptance criteria

**Technical Considerations**:
- Architecture changes required
- Database migrations needed
- API changes and versioning
- Breaking changes management
- Backward compatibility strategy

**Dependencies and Risks**:
- External dependencies
- Team dependencies
- Technical risks
- Mitigation strategies

#### 4. Epic Branch Creation

**IMPORTANT**: Create dedicated epic branch for all related work

**Worktree Mode** (if `--worktree` is used):

Read `@${CLAUDE_PLUGIN_ROOT}/templates/worktree-guide.md` for full worktree procedures.

1. Detect if already inside a worktree (CWD contains `.claude/worktrees/`). If yes, work in-place.
2. Ensure `.gitignore` includes worktrees:
   ```bash
   grep -q "\.claude/worktrees" .gitignore 2>/dev/null || echo -e "\n# Claude Code worktrees\n.claude/worktrees/" >> .gitignore
   ```
3. Create worktree with epic branch:
   ```bash
   git fetch origin
   EPIC_BRANCH="epic/<epic-name>"
   WORKTREE_DIR=".claude/worktrees/epic-<epic-name>"
   git worktree add "$WORKTREE_DIR" -b $EPIC_BRANCH origin/main
   cd "$WORKTREE_DIR" && git push -u origin $EPIC_BRANCH
   ```
4. All subsequent bash commands must run inside the worktree: `cd "$WORKTREE_DIR" && <command>`

**Standard Mode** (default, without `--worktree`):

```bash
# Ensure main branch is up to date
git checkout main
git pull origin main

# Create epic branch
EPIC_BRANCH="epic/<epic-name>"
git checkout -b $EPIC_BRANCH
git push -u origin $EPIC_BRANCH

# This branch will be the base for all epic-related PRs
```

**Branch Strategy**:
- Epic branch: `epic/<epic-name>`
- Feature branches: `feat/issue-<number>-<name>` (based on epic branch)
- PRs for features merge into epic branch
- Final PR merges epic branch into main

#### 5. Label Management

**Before creating issues**, verify and manage labels:

1. **List existing labels**: Already available in context
2. **Identify needed labels**:
   - `epic`: For main epic issue
   - `phase:1`, `phase:2`, etc.: For phase tracking
   - Type labels: `feat`, `refactor`, `docs`, etc.
   - Priority labels: `priority:high`, `priority:critical`, etc.
   - Component labels: Based on affected areas

3. **Create missing labels**:
```bash
gh label create "epic" --description "Epic issue" --color "3E4B9E"
gh label create "phase:1" --description "Phase 1" --color "0E8A16"
# ... create other needed labels
```

#### 6. Create Epic Issue

```bash
gh issue create \
  --title "[EPIC] <Epic Title>" \
  --body "$(cat <<'EOF'
## Epic Overview

<High-level description and motivation>

## Business Value

<Why this epic is important>

## Success Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Phases

### Phase 1: <Phase Name>
<Description>
Related issues: #X, #Y

### Phase 2: <Phase Name>
<Description>
Related issues: #A, #B

### Phase 3: <Phase Name>
<Description>
Related issues: #C, #D

## Technical Architecture

<High-level architectural changes>

## Dependencies

- Dependency 1
- Dependency 2

## Risks and Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| Risk 1 | High | Strategy 1 |

## Timeline

Estimated completion: <timeframe>

## Epic Branch

Development branch: `epic/<epic-name>`
- All feature PRs should target this branch
- Final epic PR will merge to main

## Related Issues

- #X - Feature 1
- #Y - Feature 2
- #Z - Feature 3

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)" \
  --label "epic,priority:high" \
  --assignee @me
```

#### 7. Create Sub-Issues

For each identified feature/task:

```bash
gh issue create \
  --title "<Issue Title>" \
  --body "$(cat <<'EOF'
Part of epic: #<epic-number>

## Description

<Feature description>

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Technical Notes

<Implementation guidance>

## Definition of Done

- [ ] Implementation complete
- [ ] Tests added
- [ ] Documentation updated
- [ ] PR reviewed and approved

## Branch Info

Base branch: `epic/<epic-name>`
Feature branch: `feat/issue-<number>-<name>`

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)" \
  --label "feat,epic-related" \
  --milestone "<milestone-if-any>"
```

#### 8. Link Issues to Epic

After creating all issues, update epic issue to link all related issues:
```bash
# Get all created issue numbers
# Update epic issue body to include links
gh issue edit <epic-number> --body "<updated-body-with-links>"
```

### Integration with Development Flow

**Epic-based Flow**: `/research` (optional) → `/epic` → `/feat` → `/dev` → `/review-pr`

**Epic in Context**:
1. **`/research`**: Gather information before epic planning (optional)
2. **`/epic`** (this command): Create comprehensive plan and epic branch
3. **`/feat`**: Create detailed specifications for epic sub-issues (optional, if more detail needed)
4. **`/dev issue#X`**: Implement individual issues targeting epic branch
5. **`/review-pr`**: Review individual PRs into epic branch
6. **Final merge**: Create PR from epic branch to main when complete

### Output to User

**During Planning**:
```
🎯 PLANNING EPIC: <Epic Name>

📋 Epic Scope:
   - Components affected: <list>
   - Estimated phases: <number>
   - Related issues to create: <number>
   - Timeline estimate: <timeframe>

🌿 Epic Branch: epic/<epic-name>
   - All feature PRs will target this branch
   - Final PR will merge to main

📝 Epic Specification:
<Present full specification for review>

Approve epic creation? (Y/n)
```

**After Creation**:
```
✅ EPIC CREATED SUCCESSFULLY

🎯 Epic Issue: #<number>
   Title: [EPIC] <Epic Title>
   URL: <github-url>

🌿 Development Branch: epic/<epic-name>
   Created and pushed to remote
   Base for all epic-related work

📋 Related Issues Created:
   ✅ #<n1> - <Feature 1>
   ✅ #<n2> - <Feature 2>
   ✅ #<n3> - <Feature 3>
   ... (<total> issues created)

🚀 Next Steps:

1. Start with first issue:
   /dev issue#<n1>

2. When creating PRs, target the epic branch:
   Base branch: epic/<epic-name>

3. Track progress in epic issue: #<number>

4. When all issues complete, create final PR:
   epic/<epic-name> → main

💡 All feature PRs should target epic/<epic-name>, not main
```

### Epic Tracking and Progress

The epic issue serves as central tracking:
- Link to all related issues
- Phase completion status
- Overall progress indicator
- Blockers and dependencies
- Timeline updates

### Considerations

- **Epic size**: Should be substantial but completable (2-8 weeks typical)
- **Issue granularity**: Sub-issues should be 1-5 days each
- **Dependencies**: Order issues to minimize blocking
- **Incremental value**: Plan for incremental delivery if possible
- **Team coordination**: Consider team capacity and availability

### Customization

For project-specific epic templates and processes:
`.claude/details/commands/epic.md`

This file can include:
- Epic template customization
- Required sections
- Approval workflows
- Milestone requirements
- Stakeholder communication
