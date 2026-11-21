# skillstack

A personal hub of agent skills, designed for my own workflow and installable into several coding agents (Claude Code, Codex, Cursor, Gemini).

> **Personal use.** This repository is built for my own workflow. If you use it, you are expected to have read the whole repository and to accept that it may change at any time without notice.

## Skills

| Skill | What it does |
| --- | --- |
| `github` | Sizes a task, splits it into issues, works one branch per issue, and opens PRs that the user merges. Never merges, never adds agent attribution. |

List them any time with `./install.sh --list`.

## Supported platforms

| Platform | Status |
| --- | --- |
| macOS, Linux | Supported (bash) |
| Windows via WSL | Should work like Linux; untested |
| Windows via Git Bash | Should work; untested. See the symlink note below |
| Windows native (PowerShell, cmd) | Not supported: the scripts are bash |

On Git Bash, `ln -s` creates copies instead of symlinks unless Windows developer mode and `MSYS=winsymlinks:nativestrict` are enabled. Copies work, but are not refreshed when `.agents/skills/<name>` changes.

## Install

### Requirements

- `bash` (macOS or Linux), `git`
- To use the `github` skill: [`gh`](https://cli.github.com/) installed and authenticated (`gh auth login`)

### Quick install (no clone)

From the project where you want the skills:

```sh
curl -fsSL https://raw.githubusercontent.com/SebastianUrdaneguiBisalaya/skillstack/main/install.sh | bash -s -- github --agents claude
```

Without arguments (`... | bash`) it asks which skills and agents to install. By default it installs the **latest tag** (falls back to `main` if there are none); every run refreshes to the latest version. Pin a version with `--version`:

```sh
curl -fsSL https://raw.githubusercontent.com/SebastianUrdaneguiBisalaya/skillstack/main/install.sh | bash -s -- github --agents claude --version v0.1.0
```

Versions are listed in `CHANGELOG.md`. Read `install.sh` before piping it to `bash`.

### Alternative: `npx skills add` (unofficial)

The [skills](https://skills.sh) CLI can install straight from this repository:

```sh
npx skills add SebastianUrdaneguiBisalaya/skillstack --skill github -a claude-code
```

Tested: it copies the whole skill (`SKILL.md`, `references/`, `scripts/`, `templates/`) and keeps the scripts executable. It does not use the selector or symlink layout of `install.sh`.

### Or clone the repository

```sh
git clone git@github.com:SebastianUrdaneguiBisalaya/skillstack.git
cd skillstack
```

### Run the installer

Run it **from the project where you want the skills**, pointing at the cloned script, or use `--target`:

```sh
cd /path/to/your-project
/path/to/skillstack/install.sh                 # interactive
```

The installer shows the available skills, asks which ones to install, then asks which agents to configure:

```
Skills:
  1) github   Size a task, split it into issues, ...
Select skills (numbers, or 'a' for all): 1

Agents (.agents is always created):
  1) .claude  2) .codex  3) .cursor  4) .gemini
Select agents (numbers, 'a' for all, empty for none): 1 2
```

Non-interactive examples:

```sh
install.sh --list                                  # list available skills
install.sh github --agents claude                  # one skill, Claude only
install.sh github --agents claude,codex            # several agents
install.sh --all --agents all                      # everything
install.sh --all --agents all --global             # into $HOME (all projects)
install.sh github --target /path/to/project        # explicit target
```

| Option | Meaning |
| --- | --- |
| `<name> ...` / `--all` / `--list` | choose skills, or list them |
| `--agents LIST` | `claude,codex,cursor,gemini` or `all` |
| `--project` / `--global` / `--target DIR` | where to install (default: current directory) |
| `--uninstall` | remove the selected skills |

### What it creates

```
your-project/
  .agents/skills/github/          # real copy (always created)
  .claude/skills/github  -> ../../.agents/skills/github   # symlink
  .codex/skills/github   -> ../../.agents/skills/github   # symlink (if selected)
```

Only the agents you select get a folder; `.agents` is always created. On Git Bash the links may be plain copies (see Supported platforms). Existing non-symlink folders are never overwritten.

### Use it

Open the project in your agent (Claude Code, Codex, Cursor, Gemini) and ask for work, for example: "add X to the project". The `github` skill sizes the task, creates the issues, works one branch per issue and opens a PR. You review and merge; the agent never merges.

### Update and uninstall

```sh
# with curl: just run the quick install again (it fetches the latest tag)
cd /path/to/skillstack && git pull               # with a clone: get the latest skills
install.sh github --agents claude                # re-run to refresh (idempotent)
install.sh github --uninstall                    # remove from .agents and agent folders
```

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
