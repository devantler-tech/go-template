# Contributing to the Go template

Help make the starter easier to use: clarify an onboarding step, improve a scaffold test or fix
a focused tooling problem. Discuss substantial changes in an
[issue](https://github.com/devantler-tech/go-template/issues) first; the template deliberately
stays minimal. Report sensitive vulnerabilities through the repository's private
[Report a vulnerability](https://github.com/devantler-tech/go-template/security/advisories/new)
form, never a public issue or PR.

This guide is for **upstream template contributions**. If you created your own project from the
template, replace it with your project's instructions. Newly created projects include
`CONTRIBUTING.md` in [.templatesyncignore](.templatesyncignore). Older projects must add and
commit that entry in their own ignore file before the sync runs: sync does not propagate changes
to the ignore file itself. If a sync PR is already open, restore your tailored guide and commit
the ignore entry before merging it; the entry does not undo changes already proposed.

## Make a first upstream change

You need Git, Go meeting [go.mod](go.mod), and a golangci-lint **v2** release compatible with that
Go version. Check `golangci-lint version`: its build toolchain must support the project's Go
version (see the [official compatibility FAQ](https://golangci-lint.run/docs/welcome/faq/)).
Network access is needed for dependency downloads. Use a POSIX shell with Bash available for the scaffold checks. No Docker, cluster,
GitHub App key or release access is needed for the local path below.

Fork `devantler-tech/go-template` on GitHub. Replace `YOUR-LOGIN` with your login:

```sh
git clone https://github.com/YOUR-LOGIN/go-template.git
cd go-template
git switch -c docs/first-contribution
```

Make a small wording improvement in `README.md`. Do **not** run `scripts/rename-placeholders.sh`
in this checkout: upstream must keep the template's module identity. Generated projects use that
script for their own initial setup, as the [README](README.md#-get-started) explains.

From the repository root, run the required local baseline, including for documentation PRs:

```sh
sh scripts/go-floor.test.sh --check-toolchain
golangci-lint fmt
go build ./...
go test ./...
golangci-lint run
git diff --check
```

Each command must exit 0; the tests report passing packages. Formatting can change Go files, so
inspect the diff and include only intentional changes. These checks are local feedback, not a
substitute for native CI or current-head review.

The first check inspects the compiler Go actually selects, not just the module's minimum.
If it rejects your installed compiler, install a patched supported release listed in
[the upstream advisory](https://pkg.go.dev/vuln/GO-2026-6809), then rerun the first command;
meeting the minimum with a newer but affected compiler is not sufficient. It does not install
software or change your environment.

For this README's onboarding instructions, also exercise the scaffold in disposable copies:

```sh
sh scripts/validate-agent-shims.test.sh
sh scripts/go-floor.test.sh
sh scripts/rename-placeholders.test.sh
sh .github/scripts/run-mockery.test.sh
```

The tests print `PASS` or `ok` and remove their temporary copies. They do not create a GitHub repository
or rename your upstream checkout. CI additionally checks shell pipelines and replays the pinned
TODO scanner on a Linux runner. See [AGENTS.md validation](AGENTS.md#validation) for the full
matrix and surface-specific checks; workflow edits also require `actionlint`.

## Submit your change

Review the diff, configure commit signing and stage explicit changed paths. For a README edit:

```sh
git add README.md
git commit -S -m "docs: clarify template onboarding"
git push -u origin docs/first-contribution
```

Open a **draft** PR to `devantler-tech/go-template:main` using the inherited
[PR template](https://github.com/devantler-tech/.github/blob/main/.github/PULL_REQUEST_TEMPLATE.md).
Explain the reader-facing problem and outcome in Why/What, link the issue for substantial work,
and put detailed validation evidence in a comment or check summary. Use a Conventional Commit
title and disclose AI assistance when used. Address findings; required CI and a successful
substantive review of the exact current head must pass before merge. A bot-pushed correction
changes that head and makes earlier review stale.

Follow the inherited [code of conduct](https://github.com/devantler-tech/.github/blob/main/.github/CODE_OF_CONDUCT.md)
and preserve the [Apache-2.0 license](LICENSE). Release, App installation and downstream CI setup
are maintainer responsibilities, not prerequisites for your first upstream contribution.
