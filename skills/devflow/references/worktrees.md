# Git Worktrees

Use this when a DevFlow workflow runs in an isolated worktree, for example when the user asks to implement an issue or review a PR "in a worktree", or when a worktree is the safest way to avoid disturbing uncommitted work.

## Location

Create worktrees under `.devflow/worktrees/` in the main checkout's root (see [Main Checkout](#main-checkout)), one directory per branch with slashes replaced by hyphens:

| Branch | Worktree directory |
|---|---|
| `feat/issue-123-auth` | `.devflow/worktrees/feat-issue-123-auth` |
| `epic/oauth-integration` | `.devflow/worktrees/epic-oauth-integration` |
| PR #45 review | `.devflow/worktrees/review-pr-45` |

`.claude/worktrees/` is the legacy root. Keep working in, and clean up, worktrees that already exist there, but never create a new one there.

## Main Checkout

Run the ignore check, any `.gitignore` edit, and every `git worktree add` from the main checkout's root, never from inside another linked worktree, whose branch must not pick up unrelated changes. This prints that root from any directory, including linked worktrees and submodules:

```bash
common=$(cd "$(git rev-parse --git-common-dir)" && pwd)
root=$(cd "$common" && cd "$(git config --file config core.worktree || echo ..)" && pwd)
if [ "$(cd "$root" && cd "$(git rev-parse --git-common-dir 2>/dev/null)" 2>/dev/null && pwd)" = "$common" ]; then echo "$root"; else echo "main checkout not found" >&2; fi
```

If it reports `main checkout not found`, as with a repository created with `--separate-git-dir`, ask the user where the main checkout is rather than guessing.

## Ignore Rule

The worktree root must be ignored before the first worktree is created. Ignore the `worktrees` subdirectory only: `.devflow/` also holds the project's committed DevFlow configuration and scripts, so ignoring `.devflow/` as a whole would silently drop them from version control.

```bash
git -C "<root>" check-ignore -v .devflow/worktrees/x   # prints source:line:pattern of the matching rule, if any
git -C "<root>" check-ignore -q --no-index .devflow/check.md && echo "the DevFlow configuration is ignored"
```

- No output from the first command: append the rule, `printf '\n# DevFlow worktrees\n.devflow/worktrees/\n' >> "<root>/.gitignore"`.
- A match that is not the repository's own `.gitignore`, such as a global excludes file, protects only this machine: add the rule to `.gitignore` as well so collaborators get it.
- If the second command prints its warning, a broader rule such as `.devflow/` hides the configuration. Tell the user which rule it is and propose narrowing it to `.devflow/worktrees/`; do not rewrite their ignore file without agreement.

## Create

Work in place only when the current checkout already is the worktree for the branch you need (`git branch --show-current` names it). Otherwise create a new one, even from inside another linked worktree, whose unrelated work must not be disturbed. From the main checkout's root:

```bash
git -C "<root>" fetch origin
# New branch from the base branch
git -C "<root>" worktree add "<root>/.devflow/worktrees/<sanitized-branch>" -b <branch> origin/<base-branch>
# Existing branch
git -C "<root>" worktree add "<root>/.devflow/worktrees/<sanitized-branch>" <existing-branch>
# PR under review, including one from a fork: fetch its head into a local branch first
git -C "<root>" fetch origin "pull/<number>/head:review-pr-<number>"
git -C "<root>" worktree add "<root>/.devflow/worktrees/review-pr-<number>" review-pr-<number>
```

`<root>` is the absolute path the Main Checkout snippet printed. Substitute it literally; a shell variable does not survive from one command to the next.

A branch can be checked out in only one worktree at a time; `git worktree list` shows where it is.

## Work Inside

Whether the working directory carries over from one command to the next depends on the client, so never rely on it. Set the working directory explicitly for every command that must run in the worktree, either through the client's working-directory option or with a `cd` prefix:

```bash
cd "<root>/.devflow/worktrees/feat-issue-123-auth" && npm run test
git -C "<root>/.devflow/worktrees/feat-issue-123-auth" status --short
```

Each worktree needs its own dependency installation. Use the install command from the project's `dev.md` configuration (see [Configuration](../SKILL.md#configuration)), or the project's usual one, such as `npm ci`, `uv sync`, or `go mod download`. Copy untracked local files such as `.env` from the main checkout only when the project needs them to run.

## Clean Up

After the PR is merged or the work is abandoned:

```bash
git -C "<root>" worktree list
git -C "<root>" worktree remove "<root>/.devflow/worktrees/<name>"
git -C "<root>" worktree prune
```

`git worktree remove` refuses when the worktree has uncommitted or untracked changes. Do not override that on your own: show the user what would be lost (`git -C <path> status --short`) and run `git worktree remove --force <path>` only when they explicitly ask for it. Run `git worktree prune` when git reports a worktree directory that no longer exists.
