# Epic Planning Workflow

Use this for large initiatives that need phases, multiple issues, dependency tracking, and an integration strategy.

## Inputs

- Epic name or initiative title.
- Optional priority.
- Optional target version or milestone.
- Optional worktree isolation for branch setup.

## Process

1. Ask for the high-level initiative description.
2. Inspect repository architecture and existing issue/branch conventions.
3. Infer phases, dependencies, risks, affected systems, and integration strategy.
4. Draft an epic plan with:
   - Overview and motivation
   - Business or product value
   - Phase breakdown
   - Related issues
   - Dependencies
   - Risks and mitigations
   - Testing and release strategy
   - Success criteria
5. Present the plan for approval before creating GitHub issues or branches.
6. If approved and GitHub is available, create the epic issue and sub-issues.
7. Create an epic branch like `epic/<epic-name>` only when the team workflow requires it or the user requested it.

## Output Template

```markdown
## Epic Overview

## Goals

## Non-Goals

## Phases

## Proposed Issues

## Dependencies

## Risks

## Testing And Release Strategy

## Success Criteria
```

## Completion

Report the epic issue, sub-issues, branch if created, and the recommended first implementation issue.
