# Go Template

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Go Report Card](https://goreportcard.com/badge/github.com/devantler-tech/go-template)](https://goreportcard.com/report/github.com/devantler-tech/go-template)
[![Go Reference](https://pkg.go.dev/badge/github.com/devantler-tech/go-template.svg)](https://pkg.go.dev/github.com/devantler-tech/go-template)

A minimal, batteries-included Go template for new projects. Skip the boilerplate — start from a clean, idiomatic scaffold with linting, CI/CD, releases, and agent tooling already wired up.

## ✨ What's included

- **Idiomatic scaffold** — a no-op `main.go` plus the conventional `cmd/`, `internal/`, and `pkg/` layout, ready for your first package.
- **Linting & formatting** — [`golangci-lint`](https://golangci-lint.run/) v2 (formatters + `default: all` linters) and [MegaLinter](https://megalinter.io/) for everything else, runnable locally via [pre-commit](https://pre-commit.com/).
- **CI/CD** — a required-checks workflow on pull requests and the merge queue, plus a [GoReleaser](https://goreleaser.com/) release pipeline (`cd.yaml`) triggered on `v*` tags.
- **Coverage** — `go test` coverage reported via [GitHub Code Quality](https://docs.github.com/code-security/code-quality).
- **Dependency management** — [Renovate](https://docs.renovatebot.com/) keeps Go modules and pinned actions current.
- **Agent-ready** — [`AGENTS.md`](AGENTS.md) conventions and a `.claude/skills/maintain` card so the autonomous Daily AI Assistant (and any agentic tool) can maintain the repo.

The minimum Go version is declared in [`go.mod`](go.mod) — the single source of truth.

## 🚀 Use this template

Create a new repository from the template with the GitHub CLI:

```bash
gh repo create my-project --template devantler-tech/go-template --public --clone
cd my-project
```

Or click **Use this template** on the [repository page](https://github.com/devantler-tech/go-template).

Then point the module at your own path:

```bash
go mod edit -module github.com/<you>/my-project
go mod tidy
```

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
go run ./<project>
```

### Test your project

```bash
go test ./...
```

## 🤖 Maintenance

This template is maintained by an autonomous AI assistant. The conventions, validation commands, and contribution workflow live in [`AGENTS.md`](AGENTS.md).
