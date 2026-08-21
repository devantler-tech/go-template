#!/usr/bin/env sh
# Hermetic ratchet: go.mod's language version must stay at or above the
# security floor that independently clears the 1.25.12 stdlib advisories.
# A later bump still passes; 1.25.12 fails. No network.
set -eu

root=$(git rev-parse --show-toplevel)
mod="${root}/go.mod"
floor_major=1
floor_minor=25
floor_patch=13

if [ ! -f "$mod" ]; then
  echo "FAIL: go.mod missing" >&2
  exit 1
fi

go_line=$(awk '
  /^[[:space:]]*\/\// { next }
  /^[[:space:]]*go[[:space:]]+/ {
    print $2
    exit
  }
' "$mod")

if [ -z "$go_line" ]; then
  echo "FAIL: no go directive in go.mod" >&2
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
