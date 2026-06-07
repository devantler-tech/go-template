#!/usr/bin/env bash
#
# Pre-commit hook helper: regenerate mocks with mockery.
#
# The scaffold ships no interfaces and no mockery config, so there is nothing to
# generate yet. This script therefore no-ops until the project adds a
# `.mockery.yml`/`.mockery.yaml`, keeping the pre-commit hook green on a fresh
# clone while wiring the (mockery) generation step the README advertises.
set -euo pipefail

# Nothing to generate until a mockery config exists.
if [[ ! -f .mockery.yml && ! -f .mockery.yaml ]]; then
	exit 0
fi

# mockery is installed via `go install github.com/vektra/mockery/v3@v3.5.4`
# (see .github/workflows/copilot-setup-steps.yml).
if ! command -v mockery >/dev/null 2>&1; then
	echo "error: mockery not found on PATH." >&2
	echo "Install it with: go install github.com/vektra/mockery/v3@v3.5.4" >&2
	exit 1
fi

exec mockery
