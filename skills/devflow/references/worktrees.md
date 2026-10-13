# Git Worktrees

Use this when a DevFlow workflow runs in an isolated worktree, for example when the user asks to implement an issue or review a PR "in a worktree", or when a worktree is the safest way to avoid disturbing uncommitted work.

## Location

Create worktrees under `.devflow/worktrees/` in the repository root, one directory per branch with slashes replaced by hyphens:

| Branch | Worktree directory |
|---|---|
| `feat/issue-123-auth` | `.devflow/worktrees/feat-issue-123-auth` |
| `epic/oauth-integration` | `.devflow/worktrees/epic-oauth-integration` |
| PR #45 review | `.devflow/worktrees/review-pr-45` |

`.claude/worktrees/` is the legacy root. Keep working in, and clean up, worktrees that already exist there, but never create a new one there.

## Ignore Rule

The worktree root must be ignored before the first worktree is created. Ignore the `worktrees` subdirectory only: `.devflow/` also holds the project's committed DevFlow configuration and scripts, so ignoring `.devflow/` as a whole would silently drop them from version control.

```bash
git check-ignore -v .devflow/worktrees/x   # prints source:line:pattern of the matching rule, if any
git check-ignore -q --no-index .devflow/check.md && echo "the DevFlow configuration is ignored"
```

- No output from the first command: append the rule, `printf '\n# DevFlow worktrees\n.devflow/worktrees/\n' >> .gitignore`.
- A match that is not the repository's own `.gitignore`, such as a global excludes file, protects only this machine: add the rule to `.gitignore` as well so collaborators get it.
- If the second command prints its warning, a broader rule such as `.devflow/` hides the configuration. Tell the user which rule it is and propose narrowing it to `.devflow/worktrees/`; do not rewrite their ignore file without agreement.

## Create

Work in place only when the current checkout already is the worktree for the branch you need (`git branch --show-current` names it). Otherwise create a new one, even from inside another linked worktree, whose unrelated work must not be disturbed. Create it from the main checkout so worktrees never nest; this prints the main checkout's root from any directory, linked worktrees included:

```bash
(cd "$(git rev-parse --git-common-dir)/.." && pwd)
```

From that directory:

```bash
git fetch origin
# New branch from the base branch
git worktree add ".devflow/worktrees/<sanitized-branch>" -b <branch> origin/<base-branch>
# Existing branch, such as a PR under review
git worktree add ".devflow/worktrees/<sanitized-branch>" <existing-branch>
```

A branch can be checked out in only one worktree at a time; `git worktree list` shows where it is.

## Work Inside

Whether the working directory carries over from one command to the next depends on the client, so never rely on it. Set the working directory explicitly for every command that must run in the worktree, either through the client's working-directory option or with a `cd` prefix:

```bash
cd ".devflow/worktrees/feat-issue-123-auth" && npm run test
git -C ".devflow/worktrees/feat-issue-123-auth" status --short
```

Each worktree needs its own dependency installation. Use the install command from the project's `dev.md` configuration (see [Configuration](../SKILL.md#configuration)), or the project's usual one, such as `npm ci`, `uv sync`, or `go mod download`. Copy untracked local files such as `.env` from the main checkout only when the project needs them to run.

## Clean Up

After the PR is merged or the work is abandoned:

```bash
git worktree list
git worktree remove ".devflow/worktrees/<name>"
git worktree prune
```

`git worktree remove` refuses when the worktree has uncommitted or untracked changes. Do not override that on your own: show the user what would be lost (`git -C <path> status --short`) and run `git worktree remove --force <path>` only when they explicitly ask for it. Run `git worktree prune` when git reports a worktree directory that no longer exists.
