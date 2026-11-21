# AGENTS.md

Instructions for any AI agent working **on this repository** (skillstack itself). They do not apply to the skills it ships; each skill carries its own `SKILL.md`.

## 1. Project context

skillstack is a personal hub of agent skills designed for the owner's own workflow. Skills are installed into projects and used by several agents (Claude Code, Codex, Cursor, Gemini, ...).

- Personal use only. Anyone using it is expected to have read the whole repository first (state this in README, CONTRIBUTING and SECURITY).
- All repository content (code, docs, comments, commits, issues, PRs) is written in **English**.
- First skill: `github`. It makes agents size tasks, split them into issues, work one branch per issue, and open PRs that a human merges.

## 2. Repository layout

```
AGENTS.md  CLAUDE.md  README.md  CONTRIBUTING.md  SECURITY.md  CODE_OF_CONDUCT.md  LICENSE
install.sh                       # interactive/CLI installer
.githooks/                       # commit-msg, pre-push (activated via core.hooksPath)
.github/                         # ISSUE_TEMPLATE/, pull_request_template.md (no CI workflows)
scripts/                         # repo-level validators (validate-skills.sh, check-commit-msg.sh, check-no-coauthor.sh)
skills/<skill-name>/
  SKILL.md                       # entry point, with frontmatter (name, description)
  references/                    # detail loaded on demand
  scripts/                       # validators and guards the skill can run
  templates/                     # templates the skill must follow
```

Rules:
- `CLAUDE.md` only contains `@AGENTS.md`. `AGENTS.md` is the single source of truth.
- A skill must be **self-contained**: it may only reference files inside its own folder, because installation links just that folder.
- No GitHub Actions / CI workflows in this repo.
- Keep empty directories with a `.gitkeep`. Empty files stay empty unless a task says otherwise.

## 3. Skill authoring best practices

- Folder name is kebab-case and equals the `name` in `SKILL.md` frontmatter.
- `description` states what the skill does and when to trigger it, in one or two sentences.
- `SKILL.md` stays short (under ~500 lines): workflow and hard rules only. Move detail to `references/` and link it.
- Prefer **enforcement over prose**: whenever a rule can be checked, ship a script in `scripts/` that checks it and prints clear, actionable errors (what is wrong, where, how to fix). Exit non-zero on failure.
- Scripts are POSIX/bash, `set -euo pipefail`, no non-standard dependencies, safe to re-run.
- Hard prohibitions are stated explicitly and, where possible, enforced by a guard script.
- Templates are mandatory formats; agents fill them, never improvise structure.
- Never invent requirements: use only what the user said.

## 4. Git and GitHub workflow (applies to this repo and to the `github` skill)

**Task sizing** (done before creating anything):
- Small = 1 issue. Medium = 2 to 3 issues. Large = 1 parent issue + sub-issues.

**Issues** follow `skills/github/templates/issue.md`: title, concrete description with no assumptions (only what the user stated), acceptance criteria, and a step-by-step checklist.

**Branches**: one branch per issue, named `type/<issue-number>-short-title` (e.g. `feat/12-add-installer`). Reuse a branch only if the user says so; then update the issues accordingly.

**Commits**: Conventional Commits, `type(scope): subject`.
- Allowed types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
- Imperative, lowercase subject, no trailing period, header up to 72 chars.
- Author identity comes from the user's `git config user.name` / `user.email`.
- **Never** add `Co-Authored-By`, "Generated with ...", or any agent attribution to commits, issues, or PRs. Validated by `check-no-coauthor.sh` and the `commit-msg` hook.

**Pull requests** follow `skills/github/templates/pull-request.md` and close their issue with `Closes #<n>`.

**Merging**: agents must **never** merge (no `gh pr merge`, no pushing to `main`, no force pushes). After opening a PR the agent stops and waits for the user to confirm they merged it. Then: `git checkout main && git pull`, and continue with the next issue.

**Allowed `gh` commands**: `gh issue create|view|list|edit`, `gh pr create|view|list|status|checks`, `gh repo view`. Everything else (notably `gh pr merge`, `gh repo delete`, `gh api -X DELETE`) is forbidden and blocked by `guard-gh.sh`.

## 5. Hooks and validation

- Hooks live in `.githooks/` and are plain shell, activated with `git config core.hooksPath .githooks` (no Node dependency). If a Node library ever becomes necessary, move to Husky.
- `commit-msg`: format and no-agent-attribution checks.
- `pre-push`: blocks pushes to `main`; runs `scripts/validate-skills.sh`.
- `validate-skills.sh` checks frontmatter, name/folder match, self-containment, and that referenced files exist.

## 6. Installer (`install.sh`)

- Lists the skills in `skills/` and lets the user pick by interactive menu or CLI args (`./install.sh github`, `--all`, `--list`). Pure bash, no packages.
- Installs the real skill into `.agents/skills/<name>` of the target project, then symlinks it into `.claude/skills/<name>`, `.codex/skills/<name>`, `.cursor/skills/<name>`, `.gemini/skills/<name>`.
- Supports `--global`, `--project` (default), `--uninstall`, and is idempotent.

## 7. Working rules for agents

- Do not start work without an issue. Size the task first.
- One issue, one branch, one PR.
- Run the validators before committing.
- Check whether the change needs a `CHANGELOG.md` entry and a new tag (section 8).
- Do not commit or push unless asked; do not touch unrelated files.

## 8. Changelog and versions

- Versions are git tags `vX.Y.Z` (semver); `CHANGELOG.md` has one entry per tag (Keep a Changelog format) and an `Unreleased` section for pending changes.
- Whenever files are added or modified, check whether `CHANGELOG.md` needs an entry and whether a new tag is needed. Update the changelog in the same PR as the change.
- Bump: patch = fixes and docs-only corrections, minor = new skills/features/options, major = breaking changes to install or skill behavior.
- Tags are created only after the PR is merged, pointing at `main`, and only with the user's approval. `install.sh` installs the latest tag by default, so an untagged change is not delivered to users.
