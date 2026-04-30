# Validation Workflow

Use this when running DevFlow quality checks: tests, linting, type checking, build, or OPSX/OpenSpec validation.

## Inputs

- Optional `fast`: skip expensive build or full-suite checks.
- Optional `verbose`: include full command output.
- Optional project-local configuration in `.claude/details/commands/check.md`.

## Process

1. Load `.claude/details/commands/check.md` if present.
2. If no config exists, infer checks from the repository:
   - Node/TypeScript: `npm run test`, `npm run lint`, `npx tsc --noEmit`, `npm run build` when scripts exist.
   - Python: `pytest`, configured linter/type checker when present.
   - Go: `go test ./...` and `go build ./...`.
3. Run independent validations in parallel when the client supports parallel tool execution. Otherwise run them sequentially and preserve the same report format.
4. Include optional OPSX/OpenSpec checks only when configured or clearly present.
5. Summarize each validation as `pass`, `warning`, `fail`, or `skipped`.
6. If failures occur and the user requested implementation or autofix, fix them and re-run the relevant checks.

## Report Template

```markdown
## Validation Results

| Check | Status | Notes |
|---|---|---|
| Tests | pass/fail/skipped | ... |
| Lint | pass/fail/skipped | ... |
| Typecheck | pass/fail/skipped | ... |
| Build | pass/fail/skipped | ... |

## Required Follow-Up

- ...
```

## Completion

Return a concise pass/fail summary. Include exact failing commands and actionable next steps when anything fails.
