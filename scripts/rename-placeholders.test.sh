#!/usr/bin/env sh
# rename-placeholders.test.sh — exercise scripts/rename-placeholders.sh end-to-end.
#
# rename-placeholders.sh is the first thing a newcomer runs after `Use this
# template`. A silent regression in it — a missed file, a botched sed address
# that rewrites an upstream link, or a leftover template module path — ships
# broken to every project created from this template, and it has no other
# coverage. This test pins its real behaviour:
#   * the module path is repointed in go.mod and every .go file,
#   * the README Go Report Card / pkg.go.dev *badges* are repointed,
#   * the upstream "Use this template" links (the repository-page URL and the
#     `--template devantler-tech/go-template` flag) are LEFT INTACT,
#   * no stray sed temp files are left behind,
#   * the renamed scaffold still builds and tests, and
#   * the input guardrails reject a non-module-path and the template's own path.
#
# It runs the script against a throwaway copy so the real working tree is never
# mutated. Run locally with `sh scripts/rename-placeholders.test.sh`; CI runs it
# via .github/workflows/validate-scaffold.yaml.
set -eu

OLD_MODULE="github.com/devantler-tech/go-template"
NEW_MODULE="github.com/example-owner/renamed-project"

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

fail() {
	echo "FAIL: $*" >&2
	exit 1
}

# Build a throwaway copy of the working tree and make it its own git repo, so the
# script's `git rev-parse` / `git grep` / `git ls-files` see exactly the
# template's files in isolation. Everything below runs inside this copy.
work="$(mktemp -d)"
trap 'rm -rf "$work" "${work2:-}" "${work3:-}"' EXIT
cp -R "$repo_root"/. "$work"/
rm -rf "$work/.git"
cd "$work"
git init -q
git add .
git -c user.email=test@example.com -c user.name=test commit -qm init

script="./scripts/rename-placeholders.sh"

# --- Guardrails: each must reject and exit non-zero, mutating nothing ----------
if "$script" "$OLD_MODULE" >/dev/null 2>&1; then
	fail "expected rejection when the new path equals the template's own"
fi
if "$script" "not a module path" >/dev/null 2>&1; then
	fail "expected rejection of an invalid module path (contains spaces)"
fi
if "$script" "nodotsorslashes" >/dev/null 2>&1; then
	fail "expected rejection of a bare name (no host/owner/name segments)"
fi
if ! git diff --quiet; then
	fail "a rejected invocation modified the tree — guardrails must bail out first"
fi

# --- Happy path ---------------------------------------------------------------
"$script" "$NEW_MODULE"

# 1) Module path repointed in go.mod and every .go file; no remnant in code.
grep -q "^module ${NEW_MODULE}\$" go.mod ||
	fail "go.mod module line not repointed to ${NEW_MODULE}"
if git grep -qF "$OLD_MODULE" -- '*.go' 'go.mod'; then
	fail "template module path still present in go.mod/*.go after rename"
fi

# 2) README badges repointed to the new module.
grep -qF "goreportcard.com/badge/${NEW_MODULE}" README.md ||
	fail "Go Report Card badge not repointed"
grep -qF "pkg.go.dev/badge/${NEW_MODULE}" README.md ||
	fail "pkg.go.dev badge not repointed"

# 3) Upstream "Use this template" links LEFT INTACT (the subtle invariant: the
#    script's address-restricted sed must skip these even though they contain
#    the template's own path/slug).
grep -qF "https://github.com/devantler-tech/go-template" README.md ||
	fail "repository-page upstream link was not preserved"
grep -qF -- "--template devantler-tech/go-template" README.md ||
	fail "--template upstream link was not preserved"

# 4) No stray temp files left behind by the in-place sed.
if git status --porcelain --untracked-files=all | grep -q '\.rename\.'; then
	fail "stray *.rename.* temp file left behind"
fi

# 5) The renamed scaffold still builds and tests.
go build ./...
go test ./...

# --- No-argument default: derive the module path from origin's GitHub remote ---
# "With no argument it derives the path from origin's GitHub remote" — the URL
# parsing (strip up to github.com, the scp `:` vs https `/`, drop the `.git`
# suffix) is the script's documented default, yet every case above passes an
# EXPLICIT path, leaving this branch unexercised. Each sub-case uses a fresh copy
# (the one above is already renamed), gives it an origin, runs the script with no
# argument, and asserts the same derived module path — both URL forms must agree.
make_copy() {
	d="$(mktemp -d)"
	cp -R "$repo_root"/. "$d"/
	rm -rf "$d/.git"
	(
		cd "$d"
		git init -q
		git add .
		git -c user.email=test@example.com -c user.name=test commit -qm init
	)
	printf '%s' "$d"
}

# https remote: github.com/<owner>/<repo>, with the .git suffix dropped.
work2="$(make_copy)"
(
	cd "$work2"
	git remote add origin "https://github.com/example-owner/renamed-project.git"
	./scripts/rename-placeholders.sh # no argument -> derive from origin
	grep -q "^module ${NEW_MODULE}\$" go.mod ||
		fail "no-arg run did not derive ${NEW_MODULE} from the https remote"
	if git grep -qF "$OLD_MODULE" -- 'go.mod' '*.go'; then
		fail "template module path still present after the derived (https) rename"
	fi
)

# scp-style remote (git@github.com:owner/repo.git) derives identically.
work3="$(make_copy)"
(
	cd "$work3"
	git remote add origin "git@github.com:example-owner/renamed-project.git"
	./scripts/rename-placeholders.sh # no argument -> derive from origin
	grep -q "^module ${NEW_MODULE}\$" go.mod ||
		fail "no-arg run did not derive ${NEW_MODULE} from the scp-style remote"
)

echo "PASS: rename-placeholders.sh end-to-end (guardrails + module repoint + no-arg remote derivation + upstream-link preservation + build/test)"
