#!/usr/bin/env sh
# Hermetic ratchet: go.mod's language version must stay at or above the
# security floor that independently clears GO-2026-6809 (crypto/x509).
# Later safe releases pass; the advisory also excludes 1.27.0–1.27.2. No network.
set -eu

root=$(git rev-parse --show-toplevel)
# Keep the regression harness inside the already sync-excluded scaffold gate.
if [ "${1:-}" = --self-test ]; then
	[ "$#" -eq 1 ] || exit 2
	work=$(mktemp -d)
	trap 'rm -rf "$work"' EXIT HUP INT TERM
	git -C "$work" init -q
	cp "$root/scripts/go-floor.test.sh" "$work/ratchet.sh"

	# check compares the isolated ratchet's exit result with the expected verdict.
	check() {
		directive=$1 expected=$2
		printf 'module example.test/scaffold\n\ngo %s\n' "$directive" >"$work/go.mod"
		if (cd "$work" && sh ./ratchet.sh) >"$work/result" 2>&1; then
			actual=pass
		else
			actual=fail
		fi
		if [ "$actual" != "$expected" ]; then
			printf 'FAIL: directive %s: expected %s, got %s\n' "$directive" "$expected" "$actual" >&2
			cat "$work/result" >&2
			exit 1
		fi
	}

	check 1.25.13 fail
	check 1.26.0 fail
	check 1.26.9 fail
	check 1.26.10 pass
	check 1.26.11 pass
	check 1.27.0 fail
	check 1.27.1 fail
	check 1.27.2 fail
	check 1.27.3 pass
	check 1.27.4 pass
	check 1.28.0 pass
	check '1.26.10 // patched minimum' pass
	check '1.26.10 extra' fail
	check 1.26.10.99 fail
	check '' fail
	check devel fail
	grep -Fx 'scripts/go-floor.test.sh' "$root/.templatesyncignore" >/dev/null || {
		printf 'FAIL: template-only regression harness must be excluded from sync\n' >&2
		exit 1
	}
	printf 'PASS: 16 Go security-floor regression controls and sync exclusion\n'
	exit 0
fi
[ "$#" -eq 0 ] || exit 2
mod="${root}/go.mod"
floor_major=1
floor_minor=26
floor_patch=10

if [ ! -f "$mod" ]; then
	echo "FAIL: go.mod missing" >&2
	exit 1
fi

go_line=$(awk '
  /^[[:space:]]*\/\// { next }
  /^[[:space:]]*go[[:space:]]+/ {
    sub(/^[[:space:]]*go[[:space:]]+/, "")
    sub(/[[:space:]]*\/\/.*$/, "")
    sub(/[[:space:]]+$/, "")
    print
    exit
  }
' "$mod")

if [ -z "$go_line" ]; then
	echo "FAIL: no go directive in go.mod" >&2
	exit 1
fi

# Validate the WHOLE directive, not just its first field. Taking `$2` accepted
# `go 1.25.13 extra` and `go 1.25.13.99` alike, because the trailing token and
# the fourth component were simply never looked at -- so a malformed directive
# could satisfy a security ratchet that had not actually parsed it. A trailing
# `//` comment is stripped above and stays allowed.
version_output=$(printf '%s\n' "$go_line") || {
	echo "FAIL: could not prepare the Go version for validation" >&2
	exit 1
}
if ! grep -qE '^[0-9]+\.[0-9]+(\.[0-9]+)?$' <<EOF; then
$version_output
EOF
	echo "FAIL: go.mod go directive is not a bare version: '${go_line}'" >&2
	exit 1
fi

IFS=.
# shellcheck disable=SC2086
set -- $go_line
unset IFS
major=${1:-0}
minor=${2:-0}
patch=${3:-0}

case "${major}${minor}${patch}" in
*[!0-9]*)
	echo "FAIL: unparseable go version '${go_line}'" >&2
	exit 1
	;;
esac

ok=0
if [ "$major" -eq 1 ] && [ "$minor" -eq 27 ] && [ "$patch" -lt 3 ]; then
	echo "FAIL: go.mod go ${go_line} is affected by GO-2026-6809; the 1.27 line requires 1.27.3" >&2
	exit 1
fi
if [ "$major" -gt "$floor_major" ]; then
	ok=1
elif [ "$major" -eq "$floor_major" ] && [ "$minor" -gt "$floor_minor" ]; then
	ok=1
elif [ "$major" -eq "$floor_major" ] && [ "$minor" -eq "$floor_minor" ] && [ "$patch" -ge "$floor_patch" ]; then
	ok=1
fi

if [ "$ok" -ne 1 ]; then
	echo "FAIL: go.mod go ${go_line} is below the security floor ${floor_major}.${floor_minor}.${floor_patch}" >&2
	exit 1
fi

echo "ok go ${go_line} >= ${floor_major}.${floor_minor}.${floor_patch}"
