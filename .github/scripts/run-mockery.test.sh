#!/usr/bin/env sh
# run-mockery.test.sh — exercise .github/scripts/run-mockery.sh end-to-end.
#
# run-mockery.sh is the `entry` of the pre-commit `mockery` hook
# (.pre-commit-config.yaml). Its whole reason to exist is the guarded no-op that
# keeps a *fresh clone's* commit green: the scaffold ships no interfaces and no
# mockery config, so the hook must do nothing until the project adds a
# `.mockery.yml`/`.mockery.yaml`, and must fail with a helpful message — not a
# bare `command not found` — once a config exists but mockery is not installed.
# A silent regression (e.g. "simplifying" it to a bare `exec mockery`) would make
# every fresh clone's first commit fail, and it has no other coverage. This test
# pins its three real behaviours:
#   * no mockery config            -> exit 0, silent no-op,
#   * config present, mockery PATH-absent -> exit 1 with an install hint,
#   * config present, mockery present     -> it is exec'd (runs to completion).
#
# It runs the REAL script against throwaway working directories with a fully
# stripped PATH, so the result never depends on whatever tools the runner
# happens to have installed (the missing-mockery case is then guaranteed, not
# probabilistic). Run locally with `sh .github/scripts/run-mockery.test.sh`; CI
# runs it via .github/workflows/validate-scaffold.yaml.
set -eu

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
script="$repo_root/.github/scripts/run-mockery.sh"
# Absolute bash path: the test below runs the (bash) script under a stripped
# PATH, so it must not depend on PATH to locate the interpreter itself.
bash_bin="$(command -v bash)"

[ -f "$script" ] || { echo "FAIL: $script not found" >&2; exit 1; }
[ -n "$bash_bin" ] || { echo "FAIL: bash not on PATH" >&2; exit 1; }

fail() {
	echo "FAIL: $*" >&2
	exit 1
}

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# --- Case 1: no mockery config -> silent no-op, exit 0 ------------------------
work1="$tmp/no-config"
mkdir -p "$work1"
out1="$tmp/out1"
err1="$tmp/err1"
rc=0
( cd "$work1" && PATH="" "$bash_bin" "$script" ) >"$out1" 2>"$err1" || rc=$?
[ "$rc" -eq 0 ] || fail "no-config case should exit 0, got $rc (stderr: $(cat "$err1"))"
[ -s "$out1" ] && fail "no-config case must be silent on stdout, got: $(cat "$out1")"
[ -s "$err1" ] && fail "no-config case must be silent on stderr, got: $(cat "$err1")"

# --- Case 2: config present, mockery absent -> exit 1 with install hint -------
work2="$tmp/config-no-mockery"
mkdir -p "$work2"
: >"$work2/.mockery.yml"
err2="$tmp/err2"
rc=0
# PATH="" makes `command -v mockery` inside the script fail deterministically.
( cd "$work2" && PATH="" "$bash_bin" "$script" ) >/dev/null 2>"$err2" || rc=$?
[ "$rc" -eq 1 ] || fail "missing-mockery case should exit 1, got $rc"
grep -qi 'mockery not found' "$err2" || fail "missing-mockery case must explain the failure (stderr: $(cat "$err2"))"
grep -qi 'go install' "$err2" || fail "missing-mockery case must print the install hint (stderr: $(cat "$err2"))"

# Also accept a .mockery.yaml (the script checks both extensions).
work2b="$tmp/config-yaml-no-mockery"
mkdir -p "$work2b"
: >"$work2b/.mockery.yaml"
rc=0
( cd "$work2b" && PATH="" "$bash_bin" "$script" ) >/dev/null 2>/dev/null || rc=$?
[ "$rc" -eq 1 ] || fail ".mockery.yaml should also trigger the run path (exit 1 when mockery absent), got $rc"

# --- Case 3: config present, mockery present -> it is exec'd -------------------
work3="$tmp/config-with-mockery"
mkdir -p "$work3"
: >"$work3/.mockery.yml"
stubbin="$tmp/bin"
mkdir -p "$stubbin"
marker="$tmp/mockery-ran"
# /bin/sh shebang (absolute) so the stub launches under the stripped PATH; it
# uses only shell built-ins, so it needs nothing else on PATH.
cat >"$stubbin/mockery" <<EOF
#!/bin/sh
echo ran >"$marker"
exit 0
EOF
chmod +x "$stubbin/mockery"
rc=0
( cd "$work3" && PATH="$stubbin" "$bash_bin" "$script" ) >/dev/null 2>/dev/null || rc=$?
[ "$rc" -eq 0 ] || fail "present-mockery case should exit 0 (exec mockery), got $rc"
[ -f "$marker" ] || fail "present-mockery case must exec mockery (stub marker not written)"

echo "PASS: run-mockery.sh (no-op without config + helpful error when mockery absent + exec when present)"
