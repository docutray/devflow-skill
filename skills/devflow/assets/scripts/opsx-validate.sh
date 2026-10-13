#!/bin/sh
# DevFlow OpenSpec validation gate (the opsx_validate check).
#
# DevFlow setup copies this file to .devflow/scripts/opsx-validate.sh in the
# repository, and .devflow/check.md runs it from the repository root:
#
#   sh .devflow/scripts/opsx-validate.sh
#
# The change name is $DEVFLOW_OPENSPEC_CHANGE when set, otherwise the last path
# segment of the current branch, lowercased. When it names an active change,
# that change is validated with --strict. Otherwise the main specs and every
# active change are validated, with a note on stderr. An explicit
# DEVFLOW_OPENSPEC_CHANGE widens that way only when it names an archived change.
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

if [ -n "$CHANGE" ] && printf '%s\n' "$ACTIVE" | names | grep -Fqx -- "$CHANGE"; then
    exec openspec validate "$CHANGE" --strict
fi

# An explicit target must at least name an archived change, either as <name>
# or as the YYYY-MM-DD-<name> id that `openspec list --archived` prints.
if [ -n "${DEVFLOW_OPENSPEC_CHANGE:-}" ] &&
    ! openspec list --archived --json 2>/dev/null | names |
        sed 'p; s/^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-//' | grep -Fqx -- "$CHANGE"; then
    echo "opsx_validate: DEVFLOW_OPENSPEC_CHANGE='$CHANGE' names no active or archived change" >&2
    exit 2
fi

# No single change to target: check the main specs and every active change, so
# the gate never passes without checking the branch's change.
echo "opsx_validate: no active change named '${CHANGE:-<detached HEAD>}'; validating the main specs and every active change" >&2
exec openspec validate --all --strict
