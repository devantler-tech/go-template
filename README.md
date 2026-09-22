# Go Template

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Go Report Card](https://goreportcard.com/badge/github.com/devantler-tech/go-template)](https://goreportcard.com/report/github.com/devantler-tech/go-template)
[![Go Reference](https://pkg.go.dev/badge/github.com/devantler-tech/go-template.svg)](https://pkg.go.dev/github.com/devantler-tech/go-template)

A starting point for new Go projects: an empty, idiomatic Go module with linting, releases, CI and
instructions for AI coding agents already set up. It is for Go developers who want to write their
first package on day one instead of assembling tooling first — built for devantler-tech
repositories and usable anywhere.

## ✨ What you get

- **A module ready for your code** — a no-op `main.go` and the standard `cmd/`, `internal/` and
  `pkg/` folders. [`pkg/example`](pkg/example) shows the house testing style, a table-driven test;
  replace it with your first package.
- **Feature flags built in** — [`pkg/featureflag`](pkg/featureflag) wires the
  [OpenFeature](https://openfeature.dev/) Go SDK, so a service can ship new behaviour switched off
  and turn it on once it is proven. Flags live in memory, so it runs with no backend until you swap
  in [flagd](https://flagd.dev/) or a hosted provider. A CLI can skip the SDK and hide experimental
  commands behind an `--experimental` opt-in instead. Delete the package once you have your own.
- **Linting from the first commit** — [golangci-lint](https://golangci-lint.run/) v2 runs a wide
  set of Go linters and formatters, and [MegaLinter](https://megalinter.io/) checks the YAML,
  Markdown and workflow files.
  A [pre-commit](https://pre-commit.com/) hook formats Go code on every commit and generates mocks
  with [mockery](https://vektra.github.io/mockery/) once you add a `.mockery.yml`.
- **Releases from your commit messages** — write
  [Conventional Commits](https://www.conventionalcommits.org/), and merging a `feat:` or `fix:` to
  `main` tags the next version. The tag makes [GoReleaser](https://goreleaser.com/) build your
  binaries and attach them to a GitHub release. Outside devantler-tech, tagging needs the GitHub
  App set up under [Staying current](#-staying-current).
- **CI and dependency updates** — a required-checks workflow gates pull requests and the merge
  queue, and [Dependabot](https://docs.github.com/code-security/dependabot) keeps Go modules and
  pinned GitHub Actions current. In devantler-tech repositories, organisation rules add the Go
  build, test, lint and coverage jobs.
- **Instructions for AI agents** — [`AGENTS.md`](AGENTS.md) gives coding agents such as Claude,
  Copilot and Cursor the project's conventions and validation commands.

The minimum Go version is whatever [`go.mod`](go.mod) declares.

## 🚀 Get started

Create your repository from the template with the [GitHub CLI](https://cli.github.com/), point the
module at it, and confirm it builds:

```bash
gh repo create my-project --template devantler-tech/go-template --public --clone
cd my-project
scripts/rename-placeholders.sh
go build ./... && go test ./...
```

The rename script replaces the template's module path in `go.mod`, the Go imports and the README
badges with your repository's path, read from its `origin` remote, then runs `go mod tidy`. Pass a
path such as `github.com/acme/widget` to choose it yourself, and review the result with `git diff`.

Prefer the browser? Click **Use this template** on the
[repository page](https://github.com/devantler-tech/go-template), clone your new repository, and run
the last two commands.

To format Go code on every commit, install [pre-commit](https://pre-commit.com/) and run
`pre-commit install` once.

## 📝 Everyday commands

| Task | Command |
| --- | --- |
| Add a dependency | `go get example.com/awesome-lib@latest` |
| Build | `go build ./...` |
| Run | `go run .` |
| Test | `go test ./...` |
| Lint | `golangci-lint run` |

`.golangci.yml` lets non-test code import only the standard library and OpenFeature, so add each
new dependency to its `depguard` allowlist.

## 🔄 Staying current

Every week a template-sync workflow opens a pull request with any changes to this template's shared
setup, so your project keeps up without copying files by hand. Files fall into three groups:

- **Synced from the template** — the CI, release and sync workflows in `.github/workflows/`, the
  shared lint configs (`.mega-linter.yml`, `.pre-commit-config.yaml`, `.editorconfig`,
  `.gitattributes`) and the `CLAUDE.md`/`GEMINI.md` shims. Change these in the template, not in
  your copy.
- **Yours** — everything listed in [`.templatesyncignore`](.templatesyncignore), which a sync never
  touches: your Go module and code, `README.md`, `AGENTS.md`, `LICENSE`, `CODEOWNERS`, and the
  configs you tailor, such as `.golangci.yml`, `.releaserc`, `dependabot.yaml` and `cspell.json`.
- **Used once** — the rename script and the template's own `validate-scaffold.yaml` check. Delete
  them after setup and syncs will not bring them back.

In devantler-tech repositories releases and the sync work out of the box. Elsewhere, take two
steps:

1. Install a GitHub App on your repository with write access to contents, issues, pull requests
   and workflows. Add its private key as the `APP_PRIVATE_KEY` secret and its client ID as the
   `APP_CLIENT_ID` variable; releases then tag on merge. Set the variable
   `TEMPLATE_SYNC_ENABLED=true` to turn the sync on too.
2. Replace `.github/workflows/ci.yaml` with your own build and test jobs — the synced one only
   collects the checks that devantler-tech's organisation rules add — and list it in
   `.templatesyncignore` so syncs keep your version.

## 🤖 Maintenance

An autonomous AI agent maintains this template. Conventions, validation commands and the
contribution workflow are in [`AGENTS.md`](AGENTS.md).
