# Security Policy

## Scope

skillstack is a personal project for my own workflow. It is provided as-is, with no support or security guarantees. If you use it, you do so knowing you have read the entire repository, including `install.sh` and every script in `skills/` and `scripts/`.

## What the code does

- `install.sh` copies skills into `.agents/skills/` and creates symlinks in agent folders under the chosen target. It only touches those paths.
- Skill scripts only validate text and check commands; they do not send data anywhere.
- Skills instruct agents to never merge pull requests, push to `main`, or use destructive `gh` commands.

## Reporting a vulnerability

Open a private security advisory on the GitHub repository, or open an issue without sensitive details. Reports are handled on a best-effort basis.
