#!/bin/sh
# DevFlow OpenSpec validation gate (the opsx_validate check).
#
# DevFlow setup copies this file to .devflow/scripts/opsx-validate.sh in the
# repository, and .devflow/check.md runs it from the root of the checkout being
# validated (the worktree when working in one):
#
#   sh .devflow/scripts/opsx-validate.sh
#
# The change name is $DEVFLOW_OPENSPEC_CHANGE when set, otherwise the last path
# segment of the current branch, lowercased. The gate then validates, with
# --strict and a note on stderr whenever it does not target the change itself:
#   - an active change of that name: that change alone;
#   - an archived change of that name, as <name> or YYYY-MM-DD-<name>: the main
#     specs only, so other people's active changes cannot fail the branch;
#   - anything else: the main specs and every active change. An explicit
#     DEVFLOW_OPENSPEC_CHANGE never falls through to this; it exits 2 instead.
#
# Exit codes:
#   0  validation passed
#   1  validation failed
#   2  broken configuration: openspec CLI missing, `openspec list` failing, or a
#      DEVFLOW_OPENSPEC_CHANGE that names no active or archived change

case "${1:-}" in
    -h | --help)
        sed -n '2,/^$/s/^# \{0,1\}//p' "$0"
        exit 0
        ;;
esac

# A detached HEAD has no branch, which leaves the name empty.
CHANGE=$(printf '%s' "${DEVFLOW_OPENSPEC_CHANGE:-$(git symbolic-ref --quiet --short HEAD 2>/dev/null | sed 's|.*/||')}" | tr '[:upper:]' '[:lower:]')

# Print the "name" values of `openspec list --json` output read from stdin.
names() {
    grep -o '"name": *"[^"]*"' | sed 's/^"name": *"//; s/"$//'
}

if ! command -v openspec >/dev/null 2>&1; then
    echo "opsx_validate: openspec CLI not found on PATH" >&2
    exit 2
fi

# Resolve the name through the CLI, never through openspec/changes/<name> on
# disk, which misses changes kept in an OpenSpec store.
if ! ACTIVE=$(openspec list --json 2>/dev/null); then
    echo "opsx_validate: openspec list failed; check the OpenSpec setup" >&2
    exit 2
fi

# --type change: a capability spec may share the change's name.
if [ -n "$CHANGE" ] && printf '%s\n' "$ACTIVE" | names | grep -Fqx -- "$CHANGE"; then
    exec openspec validate "$CHANGE" --type change --strict
fi

# The change is archived, either as <name> or as the YYYY-MM-DD-<name> id that
# `openspec list --archived` prints: its deltas now live in the main specs.
if [ -n "$CHANGE" ] &&
    openspec list --archived --json 2>/dev/null | names |
        sed 'p; s/^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-//' | grep -Fqx -- "$CHANGE"; then
    echo "opsx_validate: change '$CHANGE' is archived; validating the main specs only" >&2
    exec openspec validate --specs --strict
fi

if [ -n "${DEVFLOW_OPENSPEC_CHANGE:-}" ]; then
    echo "opsx_validate: DEVFLOW_OPENSPEC_CHANGE='$CHANGE' names no active or archived change" >&2
    exit 2
fi

# No change to target: check the main specs and every active change, so the
# gate never passes without checking the branch's change.
echo "opsx_validate: no active change named '${CHANGE:-<detached HEAD>}'; validating the main specs and every active change" >&2
exec openspec validate --all --strict
