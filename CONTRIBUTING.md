# Contributing

This repository is for personal use. It is not open for general contributions; if you work on it, read `AGENTS.md` first.

## Setup

Enable the git hooks once after cloning. They live in `.githooks/` and are plain shell:

```sh
git config core.hooksPath .githooks
```

- `commit-msg`: enforces `type(scope): subject` and rejects agent attribution (`Co-Authored-By`, "Generated with", ...).
- `pre-push`: blocks pushes to `main` and runs `scripts/validate-skills.sh`.

## Workflow

1. Size the task and open one or more issues using `skills/github/templates/issue.md`.
2. Create one branch per issue: `type/<issue-number>-short-title`.
3. Commit with Conventional Commits. Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
4. Open a pull request to `main` using the PR template, ending with `Closes #<issue-number>`.
5. The owner reviews and merges. Agents never merge.
6. `git checkout main && git pull`, then start the next issue.

## Validate

```sh
scripts/validate-skills.sh
```

## Language

Everything in this repository is written in English.
