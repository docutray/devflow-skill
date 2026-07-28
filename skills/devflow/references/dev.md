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
4. **If `openspec/config.yaml` exists, OpenSpec is required for this workflow.** Create or continue the change's planning artifacts before writing any code, delegating to `openspec-propose` for new work or `openspec-continue-change` / `openspec-update-change` for an existing change. Follow [openspec.md](openspec.md). Only when the repository has no `openspec/config.yaml` do you proceed directly from the issue.
5. Separate delivery work from post-merge work before implementing. Any task that can only happen after the pull request merges is out of scope here: deployments, production or staging verification, monitoring and alerting checks, data migrations run against production, feature-flag rollout, and post-release sign-off. Do not implement them, do not mark them complete, and do not let them block the change from being archived. Carry them verbatim into the PR body as post-merge tasks. Implement only what can be verified in the branch.
6. Prepare the workspace:
   - If dirty, protect existing changes before switching branches.
   - Use a branch name like `feat/issue-<number>-<slug>` unless the user provided one.
   - Use a worktree when requested or when it is the safest way to avoid disturbing current work.
7. Install or verify dependencies using project conventions or `.claude/details/commands/dev.md` when present.
8. Implement in small steps following existing code patterns. When OpenSpec is configured, delegate to `openspec-apply-change` and keep the tasks file in sync as work completes.
9. Add or update focused tests for changed behavior.
10. Run quick validation during development and full validation before PR. Use [check.md](check.md).
11. When OpenSpec is configured, archive the completed change **with spec synchronization** before opening the PR, delegating to `openspec-archive-change`. The archive must merge the change's delta specs into the main specs, so never pass `--skip-specs` unless the change is tooling or documentation only. Archive only after validation passes, and commit the resulting spec updates as part of the branch. See [openspec.md](openspec.md).
12. Create a PR with summary, tests, linked issue, the OpenSpec change name when relevant, and the post-merge tasks identified in step 5.

## Worktree Convention

When using worktrees, prefer `.claude/worktrees/<sanitized-branch-name>` and ensure `.claude/worktrees/` is ignored. See [assets/templates/worktree-guide.md](../assets/templates/worktree-guide.md) if detailed worktree procedures are needed.

## PR Body Template

```markdown
## Summary

## Changes

## Tests

## Post-Merge Tasks

- [ ] <task that can only be done after merge, e.g. deploy and verify in production>

## Linked Issue

Closes #<number>
```

Omit the post-merge section when there is nothing to carry. Never leave it implied: if the issue or the OpenSpec tasks file named production work, it belongs here explicitly so the reviewer and the person merging can see what remains.

## Completion

Report the PR URL/number, validation results, the archived OpenSpec change when applicable, any post-merge tasks recorded in the PR, and the recommended PR review workflow.
