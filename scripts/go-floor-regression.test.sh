#!/usr/bin/env sh
# Exercise the real ratchet in an isolated repository, without a Go download.
set -eu

root=$(git rev-parse --show-toplevel)
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
check 1.27.3 pass
check '1.26.10 // patched minimum' pass
check '1.26.10 extra' fail
check 1.26.10.99 fail
check '' fail
check devel fail
printf 'PASS: 11 Go security-floor regression controls\n'
