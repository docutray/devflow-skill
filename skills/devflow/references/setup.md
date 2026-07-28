# DevFlow Setup Workflow

Use this when configuring DevFlow for a repository, creating project-local command details, or adapting the reusable templates to a project's framework and tooling.

## Inputs

- Optional framework hint: TypeScript/Node.js, Python, Go, Ruby, Java, Rust, or another stack.
- Optional force/update intent for replacing existing DevFlow configuration.
- Optional project-specific preferences for tests, linting, type checking, build, CI, or worktree usage.

## Process

1. Inspect repository context before writing configuration:
   - git status and current branch;
   - project structure;
   - package manifests and lockfiles;
   - existing test, lint, typecheck, build, format, and CI conventions;
   - existing `.claude/details/commands/` files.
2. Infer the primary framework and package manager from repository evidence. Prefer existing scripts and CI commands over generic defaults.
3. If configuration already exists, summarize the current files and ask before overwriting unless the user explicitly requested force/update behavior.
4. Create or update project-local DevFlow configuration under:

   ```text
   .claude/details/commands/
   ├── check.md
   ├── feat.md
   ├── dev.md
   └── review-pr.md
   ```

   Create only the files that are useful for the current repository. It is acceptable to start with `check.md` and `dev.md`.
5. Use templates from [assets/templates](../assets/templates) only as examples. Adapt them to the repository's actual tools and conventions.
6. When worktree usage is configured, ensure `.claude/worktrees/` is ignored. Use [assets/templates/worktree-guide.md](../assets/templates/worktree-guide.md) for detailed worktree procedures when needed.
7. Do not install dependencies or run destructive setup commands unless the user explicitly asks. Prefer documenting commands to run.
   - This includes OpenSpec. Configure it only on explicit request, and follow [openspec.md](openspec.md): the package is `@fission-ai/openspec` (1.x, Node >= 20.19.0), installed with `npm install -g @fission-ai/openspec@latest` and initialized with `openspec init`.
   - When initializing OpenSpec, pass `--tools` for every client the team actually uses, for example `openspec init --tools claude,codex`. Each tool gets its own generated surface, and Codex receives Agent Skills only, with no slash commands.
   - Do not configure DevFlow around `/opsx:*` commands or generated skill names. Record the `openspec` CLI commands in `check.md` and `dev.md` instead, since only the CLI behaves the same on every client. Leave the user's workflow profile alone.
8. Validate generated Markdown for clarity and report the resulting DevFlow commands.

## Recommended Configuration Content

For `check.md`, include:

- Test command.
- Lint command when available.
- Typecheck command when available.
- Build command when available.
- Optional format, security, coverage, or CI gates only when configured in the project.
- OPSX/OpenSpec gates only when `openspec/config.yaml` exists. See [openspec.md](openspec.md) for the supported version and the exact commands.

For `dev.md`, include:

- Dependency installation command.
- Development server command when relevant.
- Focused test command.
- Branch naming convention.
- PR expectations.
- Project-specific gotchas.

For `feat.md` and `review-pr.md`, include only project-specific issue, label, review, or validation conventions that differ from the default DevFlow workflow.

## Output Template

```markdown
## DevFlow Setup Summary

## Detected Project Conventions

- Framework:
- Package manager:
- Tests:
- Lint:
- Typecheck:
- Build:

## Files Created Or Updated

- `.claude/details/commands/check.md` - ...
- `.claude/details/commands/dev.md` - ...

## Recommended Usage

- Feature planning: use DevFlow feature planning
- Implementation: use DevFlow development workflow
- Validation: use DevFlow validation workflow
- PR review: use DevFlow PR review workflow

## Notes

- ...
```

## Completion

Report the detected conventions, files created or updated, any assumptions made, and the next recommended DevFlow workflow.
