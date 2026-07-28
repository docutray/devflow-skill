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
5. Check the PR's post-merge tasks, when it lists any. Confirm each one genuinely cannot be done before merge. Work that is deliverable in the branch, such as a test, a migration script, or documentation, is a finding: it was deferred incorrectly and belongs in this PR.
6. When the repository has OpenSpec configured, confirm the change was archived with spec synchronization and that the resulting main spec updates are part of the diff. A PR that implements a change but leaves it unarchived, or archives it with `--skip-specs` without cause, is a blocking finding. See [openspec.md](openspec.md).
7. Run technical validation using [check.md](check.md). Use full validation when requested or when the PR has broad impact.
8. Run functional tests only when configured or explicitly requested.
9. If `fix-issues` intent is present, make focused fixes, re-run relevant checks, and document what changed.
10. Produce review findings first, ordered by severity, with file/line references when available.
11. Approve only when the user requested approval behavior and there are no blocking findings.

## Review Output

```markdown
## Findings

- Severity: file:line - issue and impact.

## Validation

- Tests:
- Lint:
- Typecheck:
- Build:
- OpenSpec change archived with specs synced: yes / no / not applicable

## Post-Merge Tasks

- Carried forward as listed / reclassified as blocking / none

## Recommendation

Approve / Request changes / Comment only
```

## Completion

Report the final recommendation and any commands run. If approved or commented via GitHub, include the PR action taken. Then hand off: merge when approved and surface any post-merge tasks recorded in the PR body, or return to the DevFlow development workflow when changes were requested.
