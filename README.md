# Go Template

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)
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

The minimum Go version is whatever [`go.mod`](go.mod) declares. This is a starter, not a runnable
application: its entry point intentionally does nothing until you add your own code.

## 🚀 Get started

You need Git, a Go toolchain meeting [`go.mod`](go.mod), and network access to download Go modules.
For the command-line route, also install the [GitHub CLI](https://cli.github.com/) and sign in to
your own GitHub account. Start in the directory where you want a new project checkout.

The next command **creates a public GitHub repository** in your account and clones it locally.
Replace `my-project` with your chosen name; use `--private` instead of `--public` if it should not
be public. Only run it when you intend to create that repository:

```bash
gh repo create my-project --template devantler-tech/go-template --public --clone
cd my-project
scripts/rename-placeholders.sh
go build ./... && go test ./...
```

Success means the build exits 0 and the example and feature-flag tests pass. `go run .` is quiet
because the starter's main function is a no-op; it does not start a server or deploy anything.

The rename script replaces the template's module path in `go.mod`, the Go imports and the README
badges with your repository's path, read from its `origin` remote, then runs `go mod tidy`. Pass a
path such as `github.com/acme/widget` to choose it yourself, and review the result with `git diff`.
Run it only in the project you created, not in an upstream template contribution checkout.

Prefer the browser? Click **Use this template** on the
[repository page](https://github.com/devantler-tech/go-template), clone your new repository, and run
`scripts/rename-placeholders.sh` followed by the build/test command from its root. Choose the new
repository's owner and visibility before creating it in the browser.

To format Go code on every commit, install [pre-commit](https://pre-commit.com/) and run
`pre-commit install` once from your project root. This optional step changes that checkout's Git
hooks; it is not needed for the initial build/test. Remove those hooks with `pre-commit uninstall`
if you no longer want them. Linting also requires a golangci-lint v2 release compatible with the
project's Go version; the [contributor guide](CONTRIBUTING.md#make-a-first-upstream-change) explains
how to check it.

## 📝 Everyday commands

| Task             | Command                 |
|------------------|-------------------------|
| Add a dependency | `go get MODULE@VERSION` |
| Build            | `go build ./...`        |
| Run              | `go run .`              |
| Test             | `go test ./...`         |
| Lint             | `golangci-lint run`     |

`MODULE` and `VERSION` are placeholders for your chosen dependency and compatible release.
`.golangci.yml` lets non-test code import only the standard library and OpenFeature, so add each
new dependency to its `depguard` allowlist.

## 🔄 Staying current

Every week a template-sync workflow opens a pull request with any changes to this template's shared
setup, so your project keeps up without copying files by hand. Files fall into three groups:

- **Synced from the template** — the CI, release and sync workflows in `.github/workflows/`, the
  shared lint configs (`.mega-linter.yml`, `.pre-commit-config.yaml`, `.editorconfig`,
  `.gitattributes`) and the `CLAUDE.md`/`GEMINI.md` shims. Change these in the template, not in
  your copy.
- **Yours** — everything listed in your project's own `.templatesyncignore`, which a sync never
  touches. The [supplied file](.templatesyncignore) protects your Go module and code, `README.md`,
  `CONTRIBUTING.md`, `AGENTS.md`, `LICENSE`, `CODEOWNERS`, and the
  configs you tailor, such as `.golangci.yml`, `.releaserc`, `dependabot.yaml` and `cspell.json`.
- **Used once** — the rename script and the template's own `validate-scaffold.yaml` check. Delete
  them after setup and syncs will not bring them back.

**Existing projects need a one-time documentation migration.** The sync action does not copy
updates to `.templatesyncignore` itself. Before accepting a sync that introduces this contribution
guide, add the literal line `CONTRIBUTING.md` to your project's own `.templatesyncignore` and commit
it, preserving your existing guide. Projects created from the updated template already include
that entry. Review future ownership changes in your own ignore file too; an upstream addition
does not automatically protect an older project.

The template's scaffold check also scans its shell scripts with the shared shell-pipeline
validator at an immutable release pin. It checks both script directories, requires a completed
scan, and leaves the existing onboarding and mockery checks in place.

In devantler-tech repositories releases and the sync work out of the box. Elsewhere, take two
steps:

1. Install a GitHub App on your repository with write access to contents, issues, pull requests
    and workflows. Add its private key as the `APP_PRIVATE_KEY` secret and its client ID as the
    `APP_CLIENT_ID` variable; releases then tag on merge. Set the variable
    `TEMPLATE_SYNC_ENABLED=true` to turn the sync on too.
2. Replace `.github/workflows/ci.yaml` with your own build and test jobs — the synced one only
    collects the checks that devantler-tech's organisation rules add — and list it in
    `.templatesyncignore` so syncs keep your version.

## Contributing

Want to improve the template itself? Follow [CONTRIBUTING.md](CONTRIBUTING.md) for a safe upstream
checkout, local checks and submission. In a generated project, replace this link's guide with
that project's contribution instructions; the documentation is instance-owned.

## 🤖 Maintenance

An autonomous AI agent maintains this template. Its canonical engineering contract and full
validation matrix are in [`AGENTS.md`](AGENTS.md). Preserve the [Apache-2.0 license](LICENSE).
