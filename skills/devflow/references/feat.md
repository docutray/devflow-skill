# Feature Planning Workflow

Use this when creating a feature, fix, refactor, docs, test, or chore specification and a GitHub issue.

## Inputs

- Feature name or short title.
- Optional type: `feat`, `fix`, `docs`, `refactor`, `test`, or `chore`.
- Optional priority: `low`, `medium`, `high`, or `critical`.

## Process

1. Inspect repository context: git status, current branch, recent commits, remote, project structure, and existing issue/PR conventions.
2. Ask for a high-level description first. Ask follow-up questions only for critical ambiguity that cannot be inferred.
3. Analyze affected components and existing implementation patterns.
4. Draft an issue specification with:
   - Description
   - Motivation
   - Acceptance criteria
   - Technical approach
   - Affected components
   - Implementation checklist
   - Testing strategy
   - Dependencies and risks
   - Definition of done
5. Present the draft for user approval before creating the issue.
   - OpenSpec is not required for feature planning. When the repository has it configured and the user wants specs before implementation, delegate to the skill present for creating a change (usually `openspec-propose`) and keep the GitHub issue as the source of truth for scope. See [openspec.md](openspec.md) for resolving the skill and for the CLI fallback.
6. If using GitHub, verify labels with `gh label list` and create missing labels only when appropriate.
7. Create the issue after approval and report the issue number plus the recommended next workflow.

## Output Template

```markdown
## Description

## Motivation

## Acceptance Criteria

- [ ] ...

## Technical Approach

## Affected Components

## Implementation Checklist

- [ ] ...

## Testing Strategy

## Dependencies

## Considerations

## Definition of Done

- [ ] Implementation complete
- [ ] Tests added or updated
- [ ] Documentation updated when needed
- [ ] All acceptance criteria met
```

## Completion

After creating the issue, suggest implementation with the DevFlow development workflow for `issue#<number>`.
