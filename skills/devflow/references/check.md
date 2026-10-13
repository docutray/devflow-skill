# Validation Workflow

Use this when running DevFlow quality checks: tests, linting, type checking, build, or OPSX/OpenSpec validation.

## Inputs

- Optional `fast`: skip expensive build or full-suite checks.
- Optional `verbose`: include full command output.

## Process

1. Resolve the `check` configuration as described in [Configuration](../SKILL.md#configuration). When it exists, run its enabled validations as described in [Configuration Format](#configuration-format).
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
   - Rust (`Cargo.toml`): `cargo build`, `cargo test`, and `cargo fmt --check`, plus
     `cargo clippy -- -D warnings` only when clippy is installed (`cargo clippy --version`
     succeeds). `cargo test` alone is the `fast` path.
3. Run independent validations in parallel when the client supports parallel tool execution. Otherwise run them sequentially and preserve the same report format.
4. Include the OpenSpec validation gate only when `openspec/config.yaml` is present. It validates the branch's change, or the main specs and every active change when the branch names none, and exits `2` for broken configuration rather than `1`; [The Validation Gate](openspec.md#the-validation-gate) defines how it picks its target and how to report each exit code.
5. Summarize each validation as `pass`, `warning`, `fail`, or `skipped`.
6. If failures occur and the user requested implementation or autofix, fix them and re-run the relevant checks.

## Configuration Format

`.devflow/check.md` is Markdown around one fenced JSON block. Each entry under `validations` is one check, keyed by its name:

| Key | Meaning |
|---|---|
| `command` | Shell command, run from the repository root. |
| `description` | What the check covers; use it in the report. |
| `enabled` | `false` keeps the entry but never runs it. |
| `skip_on_fast` | Optional. `true` skips the check when `fast` is requested. |

```json
{
  "validations": {
    "tests": {
      "command": "npm run test",
      "description": "Unit tests",
      "enabled": true
    },
    "build": {
      "command": "npm run build",
      "description": "Production build",
      "enabled": true,
      "skip_on_fast": true
    }
  }
}
```

Prose around the block may add project notes; follow them. The framework examples in [assets/templates](../assets/templates) show fuller configurations.

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
