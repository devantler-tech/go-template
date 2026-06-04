# GitHub Copilot review instructions — go-template

`devantler-tech/go-template` is a **minimal Go project template**: an idiomatic,
no-op scaffold plus the house tooling (lint, CI/CD, release, agent config) so new
modules start from a current baseline. Enforce the rules below when reviewing.
They complement `AGENTS.md` (the canonical, cross-tool instructions) — keep both
in sync; if a PR changes a convention here, it updates `AGENTS.md` too.

## Scope & altitude
- This is a **template, not a product** — flag any PR that adds application
  features, business logic, or non-scaffold dependencies. The bias is minimal,
  idiomatic, current.
- `main.go` is intentionally a no-op; `cmd/` and `internal/` are empty `.gitkeep`
  placeholders, and `pkg/` ships one intentional sample package (`pkg/example/`, a
  real tested unit meant to be deleted/replaced). Don't approve filler code added
  beyond that.

## Go & toolchain
- `go.mod` is the **single source of truth** for the Go version — flag any
  hardcoded Go version in prose, docs, or workflows that could drift from it. The
  floor is tooling-driven (the reusable Dead Code Analysis check needs Go ≥ 1.25),
  not a language-feature need.
- Idiomatic Go: handle every error (no silent `_ =` discards of an error), no
  panics on library paths, table-driven tests, `context.Context` as the first
  parameter where used.

## Lint & format (golangci-lint v2)
- `.golangci.yml` runs formatters (gci, gofmt, gofumpt, goimports, golines,
  swaggo) plus `default: all` linters. Code must pass `golangci-lint fmt` and
  `golangci-lint run` — flag formatting drift and newly-introduced lint findings.
- Never suppress a linter with `//nolint` to dodge a finding — fix the root cause.
  Flag any added `//nolint` that lacks a specific, justified reason.

## Commits, CI & security
- **PR titles must be Conventional Commits** (`feat:`/`fix:`/`chore:`/`docs:`/
  `ci:`/`refactor:`/`test:`) — the repo squash-merges the title into the
  changelog/release, so a non-conventional or bracket-prefixed title corrupts it.
  Flag violations.
- Workflow changes must pass `actionlint`. Pin third-party actions to a
  full-length commit SHA, set least-privilege `permissions:`, and keep the house
  workflows intact (`ci.yaml` is the required-checks aggregator; `cd.yaml` runs
  GoReleaser on `v*` tags). Flag unpinned actions and over-broad token scopes.
- Never weaken or skip a check to make CI pass (no `t.Skip`, `--no-verify`,
  disabled steps, or "flaky"-dismissals) — fix the underlying cause.

## Generated & config files
- Don't hand-edit generated artifacts; re-run the generator instead. Keep the
  `README` and badges accurate to what actually ships.

Keep this file concise (≤ 4000 chars — Copilot review truncates beyond that) and
in sync with `AGENTS.md`.
