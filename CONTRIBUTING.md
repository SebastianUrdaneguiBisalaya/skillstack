# Contributing

This repository is for personal use. Read `AGENTS.md` before changing anything.

## Enable git hooks

Hooks live in `.githooks/` and are plain shell. After cloning, run once:

```sh
git config core.hooksPath .githooks
```

- `commit-msg`: enforces `type(scope): subject` and rejects agent attribution (`Co-Authored-By`, "Generated with", ...).
- `pre-push`: blocks pushes to `main`; work on a branch and open a pull request.
