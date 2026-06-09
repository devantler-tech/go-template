#!/usr/bin/env sh
# rename-placeholders.sh — turn this scaffold into your own module in one shot.
#
# Fresh from `Use this template`, the project still carries the template's module
# path `github.com/devantler-tech/go-template`. It appears in three kinds of place:
#   • go.mod          — the `module` line.
#   • *.go            — import paths (e.g. pkg/example's test imports the module).
#   • README.md       — the Go Report Card / pkg.go.dev *badge* URLs.
# Doing this by hand is easy to get half-wrong, so this script repoints all three
# WITHOUT touching the references that MUST keep pointing at the upstream template:
#   • README's "Use this template" links (`--template devantler-tech/go-template`
#     and the `[repository page]` link) — those describe where the template lives.
#
# Usage:  scripts/rename-placeholders.sh [module-path]
#   e.g.  scripts/rename-placeholders.sh github.com/acme/widget
# With no argument it derives the path from origin's GitHub remote.
set -eu

OLD_MODULE="github.com/devantler-tech/go-template"

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

new_module="${1:-}"
if [ -z "$new_module" ]; then
	remote="$(git -C "$repo_root" remote get-url origin 2>/dev/null || true)"
	case "$remote" in
	*github.com[:/]*)
		path="${remote#*github.com}" # strip up to and incl. github.com
		path="${path#:}"             # scp-style  git@github.com:owner/repo
		path="${path#/}"             # https      .../owner/repo
		path="${path%.git}"
		[ -n "$path" ] && new_module="github.com/$path"
		;;
	esac
fi

if [ -z "$new_module" ]; then
	echo "usage: scripts/rename-placeholders.sh <module-path>" >&2
	echo "       e.g. scripts/rename-placeholders.sh github.com/acme/widget" >&2
	echo "       (could not derive it from origin's GitHub remote)." >&2
	exit 1
fi

if [ "$new_module" = "$OLD_MODULE" ]; then
	echo "error: the new module path equals the template's own ($OLD_MODULE)." >&2
	echo "       run this in a project created from the template, with your own path." >&2
	exit 1
fi

# A Go module path is host(/segment)+ — reject anything that obviously is not one.
if ! printf '%s' "$new_module" | grep -Eq '^[A-Za-z0-9._~-]+(/[A-Za-z0-9._~-]+)+$'; then
	echo "error: '$new_module' does not look like a module path (host/owner/name)." >&2
	exit 1
fi

changed=0

# 1) Code: go.mod + every tracked .go file — repoint the module path everywhere.
code_files="$(git -C "$repo_root" grep -lF "$OLD_MODULE" -- '*.go' 'go.mod' 2>/dev/null || true)"
# 2) README badges only: restrict the substitution to badge-service lines so the
#    "Use this template" upstream links are left intact.
readme_files="$(git -C "$repo_root" grep -lF "$OLD_MODULE" -- 'README.md' 2>/dev/null || true)"

for f in $code_files; do
	abs="$repo_root/$f"
	tmp="$abs.rename.$$"
	sed "s|$OLD_MODULE|$new_module|g" "$abs" >"$tmp"
	if cmp -s "$abs" "$tmp"; then rm -f "$tmp"; else
		mv "$tmp" "$abs"
		changed=$((changed + 1))
	fi
done

for f in $readme_files; do
	abs="$repo_root/$f"
	tmp="$abs.rename.$$"
	# One address per service — BSD sed (macOS) has no GNU `\|` alternation.
	sed \
		-e "/goreportcard\.com/ s|$OLD_MODULE|$new_module|g" \
		-e "/pkg\.go\.dev/ s|$OLD_MODULE|$new_module|g" \
		"$abs" >"$tmp"
	if cmp -s "$abs" "$tmp"; then rm -f "$tmp"; else
		mv "$tmp" "$abs"
		changed=$((changed + 1))
	fi
done

# Normalise go.mod/go.sum if the Go toolchain is available (no-op for a pure rename).
if command -v go >/dev/null 2>&1; then
	(cd "$repo_root" && go mod tidy)
fi

echo "renamed $OLD_MODULE -> $new_module across $changed file(s)."
echo "next: review 'git diff', then 'go build ./... && go test ./...'."
