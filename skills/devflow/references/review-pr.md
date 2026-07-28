# Pull Request Review Workflow

Use this when reviewing a pull request for technical quality, test coverage, implementation correctness, and readiness to approve.

## Inputs

- Required PR number or URL.
- Optional flags or user intent: fix issues, run full suite, auto approve, functional tests, skip functional tests, worktree isolation.

## Process

1. Fetch PR metadata and diff with GitHub CLI when available.
2. Identify the linked issue and acceptance criteria.
3. Prepare a safe review workspace:
   - Prefer an isolated worktree when requested or when the current branch has unrelated work.
   - Do not discard local changes.
4. Inspect changed files for correctness, regressions, missing tests, security issues, and maintainability risks.
5. Run technical validation using [check.md](check.md). Use full validation when requested or when the PR has broad impact.
6. Run functional tests only when configured or explicitly requested.
7. If `fix-issues` intent is present, make focused fixes, re-run relevant checks, and document what changed.
8. Produce review findings first, ordered by severity, with file/line references when available.
9. Approve only when the user requested approval behavior and there are no blocking findings.

## Review Output

```markdown
## Findings

- Severity: file:line - issue and impact.

## Validation

- Tests:
- Lint:
- Typecheck:
- Build:

## Recommendation

Approve / Request changes / Comment only
```

## Completion

Report the final recommendation and any commands run. If approved or commented via GitHub, include the PR action taken. Then hand off: merge when approved and surface any post-merge tasks recorded in the PR body, or return to the DevFlow development workflow when changes were requested.
