# skillstack

A personal hub of agent skills, designed for my own workflow and installable into several coding agents (Claude Code, Codex, Cursor, Gemini).

> **Personal use.** This repository is built for my own workflow. If you use it, you are expected to have read the whole repository and to accept that it may change at any time without notice.

## Skills

| Skill | What it does |
| --- | --- |
| `github` | Sizes a task, splits it into issues, works one branch per issue, and opens PRs that the user merges. Never merges, never adds agent attribution. |

List them any time with `./install.sh --list`.

## Install

```sh
git clone git@github.com:SebastianUrdaneguiBisalaya/skillstack.git
cd skillstack
./install.sh                      # interactive: pick skills and agents
```

Non-interactive examples:

```sh
./install.sh github --agents claude,codex      # into the current directory
./install.sh --all --agents all --global       # into $HOME
./install.sh github --uninstall                # remove
```

Skills are copied to `.agents/skills/<name>` (always created) and symlinked into `.claude/`, `.codex/`, `.cursor/` or `.gemini/` for the agents you choose. Run `./install.sh --help` for all options.

## Layout

```
skills/<name>/    SKILL.md, references/, scripts/, templates/
scripts/          repo-level validators
.githooks/        commit-msg, pre-push
install.sh        installer
```

See `AGENTS.md` for the rules used to develop this repository, and `CONTRIBUTING.md` to set up the hooks.

## License

See `LICENSE`.
