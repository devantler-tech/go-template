#!/usr/bin/env bash
# Exercise the real CI reducer, not a second implementation of its decision.
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
workflow="${1:-$root/.github/workflows/ci.yaml}"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
fail() { echo "CI contract: $*" >&2; exit 1; }
yq -o=json '.' "$workflow" >"$scratch/workflow.json"
jq -e '
  .on | has("pull_request") and has("merge_group")
' "$scratch/workflow.json" >/dev/null || fail 'PR and merge queue triggers are required'
jq -e '
  .jobs["go-validation"] as $go |
  ($go.uses | test("^devantler-tech/\\.github/\\.github/workflows/validate-go-project\\.yaml@[0-9a-f]{40}$")) and
  $go.with["pr-owner"] == "${{ github.event.pull_request.user.login }}" and
  $go.with["apply-signed-fixes"] == "${{ github.repository_owner == '\''devantler-tech'\'' }}" and
  $go.secrets == {"APP_PRIVATE_KEY":"${{ secrets.APP_PRIVATE_KEY }}"} and
  $go.permissions == {"contents":"read","pull-requests":"write","issues":"write","code-quality":"write"} and
  .permissions == {} and
  .jobs["required-checks"].needs == ["go-validation"] and
  .jobs["required-checks"].if == "always()" and
  ([.jobs["required-checks"].steps[] | select(.id == "result")] | length) == 1 and
  .jobs["required-checks"].steps[0].env == {
    "VALIDATION_RESULT":"${{ needs.go-validation.result }}",
    "EVENT_NAME":"${{ github.event_name }}"
  }
' "$scratch/workflow.json" >/dev/null || fail 'native validator must feed the always-running reducer with bounded permissions'
yq -r '.jobs.required-checks.steps[] | select(.id == "result") | .run' "$workflow" >"$scratch/reducer.sh"
for event in pull_request merge_group; do
  for result in success failure cancelled abandoned skipped missing; do
    value="$result"
    [[ "$result" != missing ]] || value=''
    expected=1
    case "$event:$result" in
      pull_request:success|merge_group:success|merge_group:skipped) expected=0 ;;
    esac
    actual=0
    VALIDATION_RESULT="$value" EVENT_NAME="$event" bash -euo pipefail "$scratch/reducer.sh" >"$scratch/output" 2>&1 || actual=$?
    if [[ "$actual" != "$expected" ]]; then
      cat "$scratch/output" >&2
      fail "$event/$result returned $actual, expected $expected"
    fi
  done
done
echo 'CI contract: native caller and 12 real reducer outcomes passed'
