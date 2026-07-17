# Go Template

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Go Report Card](https://goreportcard.com/badge/github.com/devantler-tech/go-template)](https://goreportcard.com/report/github.com/devantler-tech/go-template)
[![Go Reference](https://pkg.go.dev/badge/github.com/devantler-tech/go-template.svg)](https://pkg.go.dev/github.com/devantler-tech/go-template)

A minimal, batteries-included Go template for new projects. Skip the boilerplate — start from a clean, idiomatic scaffold with linting, CI/CD, releases, and agent tooling already wired up.

## ✨ What's included

- **Idiomatic scaffold** — a no-op `main.go` plus the conventional `cmd/`, `internal/`, and `pkg/` layout, ready for your first package. A minimal [`pkg/example`](pkg/example) package with a table-driven test shows the house testing pattern — replace it with your own.
- **Feature-flag-first** — [`pkg/featureflag`](pkg/featureflag) wires the portable [OpenFeature](https://openfeature.dev/) Go SDK so a **service** can land every new feature behind a flag, default-off, and flip it on only after validation (swap the in-memory provider for [flagd](https://flagd.dev/) or a managed backend). A **CLI** can stay dependency-free instead — gate experimental commands behind cobra `Hidden` + an `--experimental` opt-in, reaching for the SDK only when you need richer evaluation. Delete it when you add your own.
- **Linting & formatting** — [`golangci-lint`](https://golangci-lint.run/) v2 (formatters + `default: all` linters) in CI, with [MegaLinter](https://megalinter.io/) covering everything else. A [pre-commit](https://pre-commit.com/) hook runs `golangci-lint` formatting (and `mockery` mock generation) locally on commit.
- **CI/CD** — a required-checks workflow on pull requests and the merge queue, plus a [GoReleaser](https://goreleaser.com/) release pipeline (`cd.yaml`) triggered on `v*` tags.
- **Coverage** — `go test` coverage reported via [GitHub Code Quality](https://docs.github.com/code-security/code-quality).
- **Dependency management** — [Dependabot](https://docs.github.com/code-security/dependabot) keeps Go modules and pinned GitHub Actions current (daily).
- **Agent-ready** — [`AGENTS.md`](AGENTS.md) conventions and a `.claude/skills/maintain` card so the autonomous Daily AI Assistant (and any agentic tool) can maintain the repo.

The minimum Go version is declared in [`go.mod`](go.mod) — the single source of truth.

## 🚀 Use this template

Create a new repository from the template with the GitHub CLI:

```bash
gh repo create my-project --template devantler-tech/go-template --public --clone
cd my-project
```

Or click **Use this template** on the [repository page](https://github.com/devantler-tech/go-template).

Then personalise the scaffold — repoint the module path (in `go.mod`, the Go
imports, and the README badges) in one shot:

```bash
scripts/rename-placeholders.sh github.com/<you>/my-project
```

Run with no argument to derive the path from your `origin` GitHub remote. The
script leaves the upstream **Use this template** links above untouched, runs
`go mod tidy`, and you can review the result with `git diff`. (Prefer to do it
by hand? `go mod edit -module github.com/<you>/my-project && go mod tidy`.)

## 🔄 Staying current

A weekly **template-sync** workflow opens a PR in your repository whenever this
template's shared plumbing changes, so instances never drift from the
portfolio's CI/lint/agent-file conventions. It never touches your code: every
file falls into one of three ownership classes:

- **Template-owned plumbing** — synced downstream by the weekly PR: the
  `.github/workflows/` CI/CD/release workflows, the shared lint configs
  (`.mega-linter.yml`, `.pre-commit-config.yaml`, `.editorconfig`,
  `.gitattributes`), and the `CLAUDE.md`/`GEMINI.md` shims.
  Change these upstream in the template, never by hand in an instance.
- **Instance-owned** — listed in [`.templatesyncignore`](.templatesyncignore),
  never touched by a sync: your Go module and code (`go.mod`, `go.sum`,
  `main.go`, `cmd/`, `internal/`, all of `pkg/`), identity and docs
  (`README.md`, `AGENTS.md`, `LICENSE`, `CODEOWNERS`), and the configs you
  tailor (`.releaserc`, `.gitignore`, `dependabot.yaml`, `.golangci.yml` —
  its depguard allowlist grows with your dependencies — and `cspell.json`).
- **Scaffold-time-only** — the rename script and the template's own
  `validate-scaffold.yaml` gate arrive when the repo is created and are ignored
  by sync afterwards, so you can delete them and they stay gone.

The sync workflow no-ops in this template repository itself. In devantler-tech
instances it works out of the box (the org provides the App credentials); an
instance elsewhere is off by default — opt in by supplying your own GitHub App
(one allowed to open PRs in your repository): add its private key as the
`APP_PRIVATE_KEY` secret, its client ID as the `APP_CLIENT_ID` repository
variable (the reusable workflow mints its token from that variable/secret
pair), and set the repository variable `TEMPLATE_SYNC_ENABLED=true`. Note that
outside devantler-tech the synced `ci.yaml` is only an empty required-check
aggregator (the real build/test workflows are injected by devantler-tech org
rulesets): replace it with your own CI and add `.github/workflows/ci.yaml` to
your `.templatesyncignore` so later syncs preserve your version.

## 📝 Usage

### Add a dependency

```bash
go get example.com/awesome-lib@latest
```

### Build your project

```bash
go build ./...
```

### Run your project

```bash
go run .
```

### Test your project

```bash
go test ./...
```

## 🤖 Maintenance

This template is maintained by an autonomous AI assistant. The conventions, validation commands, and contribution workflow live in [`AGENTS.md`](AGENTS.md).
