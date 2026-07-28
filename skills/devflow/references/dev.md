# Development Workflow

Use this when implementing a GitHub issue and preparing a pull request.

## Inputs

- Required issue reference, usually `issue#<number>`.
- Optional branch name.
- Optional flags or user intent: draft PR, auto tests, full validation, worktree isolation.

## Process

1. Inspect git status, current branch, current diff, recent commits, and remote URL.
2. Fetch the issue with `gh issue view <number> --json title,body,assignees,labels,milestone,state,comments` when GitHub CLI is available.
3. Validate the issue has enough acceptance criteria and implementation detail. Ask only for missing critical details.
4. If OPSX/OpenSpec is configured (`openspec/config.yaml`), create or continue planning artifacts before implementation, following [openspec.md](openspec.md). Otherwise proceed directly from the issue.
5. Prepare the workspace:
   - If dirty, protect existing changes before switching branches.
   - Use a branch name like `feat/issue-<number>-<slug>` unless the user provided one.
   - Use a worktree when requested or when it is the safest way to avoid disturbing current work.
6. Install or verify dependencies using project conventions or `.claude/details/commands/dev.md` when present.
7. Implement in small steps following existing code patterns.
8. Add or update focused tests for changed behavior.
9. Run quick validation during development and full validation before PR. Use [check.md](check.md).
10. When OpenSpec is configured, archive the completed change before opening the PR. See [openspec.md](openspec.md).
11. Create a PR with summary, tests, linked issue, and OPSX/OpenSpec change name when relevant.

## Worktree Convention

When using worktrees, prefer `.claude/worktrees/<sanitized-branch-name>` and ensure `.claude/worktrees/` is ignored. See [assets/templates/worktree-guide.md](../assets/templates/worktree-guide.md) if detailed worktree procedures are needed.

## PR Body Template

```markdown
## Summary

## Changes

## Tests

## Linked Issue

Closes #<number>
```

## Completion

Report the PR URL/number, validation results, and the recommended PR review workflow.
