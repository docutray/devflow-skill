# Validation Workflow

Use this when running DevFlow quality checks: tests, linting, type checking, build, or OPSX/OpenSpec validation.

## Inputs

- Optional `fast`: skip expensive build or full-suite checks.
- Optional `verbose`: include full command output.
- Optional project-local configuration in `.devflow/check.md`, or legacy `.claude/details/commands/check.md`.

## Process

1. Load `.devflow/check.md` if present, otherwise the legacy `.claude/details/commands/check.md`.
2. If no config exists, infer checks from the repository:
   - Prefer commands already used by the project in package scripts, task files, Makefiles, CI workflows, or documentation.
   - Node/TypeScript: detect the package manager from lockfiles before choosing commands:
     - `pnpm-lock.yaml` -> `pnpm` / `pnpm exec`
     - `yarn.lock` -> `yarn` / `yarn exec` when supported
     - `bun.lock` or `bun.lockb` -> `bun` / `bunx`
     - `package-lock.json` or no alternative lockfile -> `npm` / `npx`
     Run only scripts that exist, such as `<pm> run test`, `<pm> run lint`, `<pm> run typecheck` or `<pm> run type-check`, and `<pm> run build`. Use the project TypeScript script when available; otherwise use the matching exec command for `tsc --noEmit` only when TypeScript is configured.
   - Python: `pytest`, configured linter/type checker when present.
   - Go: `go build ./...`, `go test ./...`, and `go vet ./...`. Keep vet as its own check:
     `go test` runs only a high-confidence subset of the vet checks.
   - Ruby: prefix every command with `bundle exec` when a `Gemfile` is present, so the gems
     resolved in `Gemfile.lock` are the ones that run. `bundle exec` installs nothing, so run
     `bundle install` first when the gems are missing.
     - RSpec configured -> `bundle exec rspec`
     - Rake-driven Minitest -> `bundle exec rake test`
     - `bundle exec rubocop`, or the configured linter, when one is set up
     - No `Gemfile` -> invoke `rspec`, `rake`, or `ruby -Itest` directly
   - JVM: prefer a committed wrapper over a system install, since the wrapper pins the build tool
     version. Use `gradlew.bat` / `mvnw.cmd` on Windows, and `sh gradlew` when the executable bit
     is missing. Run the aggregate task the project defines for CI when it has one, and reach for
     these defaults only otherwise:
     - Gradle -> `./gradlew build`, which runs `check` and therefore the tests. `./gradlew test`
       alone is the `fast` path.
     - Maven -> `./mvnw verify`, which runs the `test` phase on the way. `./mvnw test` alone is
       the `fast` path.
     - sbt -> `sbt test`, or `sbt compile` when only a build check is wanted.
     - No wrapper -> `gradle`, `mvn`, or `sbt` according to `build.gradle`/`build.gradle.kts`,
       `pom.xml`, or `build.sbt`.
3. Run independent validations in parallel when the client supports parallel tool execution. Otherwise run them sequentially and preserve the same report format.
4. Include optional OPSX/OpenSpec checks only when `openspec/config.yaml` is present. Use the commands in [openspec.md](openspec.md); `openspec validate <change> --strict` is the pre-PR gate. The target is mandatory: with no change name and no `--changes` / `--specs` / `--all`, the command validates nothing at all — it exits `1` with a hint when run non-interactively, and opens a picker when run in a terminal. Report such a gate as broken configuration, never as a validation failure.
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

Return a concise pass/fail summary. Include exact failing commands and actionable next steps when anything fails. Validation is a step inside other workflows, so hand control back to the workflow that invoked it rather than recommending a new one; when run on its own, recommend the workflow that fits the result.
