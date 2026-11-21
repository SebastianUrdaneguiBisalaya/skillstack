#!/usr/bin/env bash
# Validates every skill in skills/.
# Checks: SKILL.md exists, frontmatter (name, description), name == folder,
# self-containment (no references outside the skill), and referenced files exist.
# Usage: validate-skills.sh [skill-name ...]   (default: all skills)
set -euo pipefail

root="$(git rev-parse --show-toplevel)"
cd "$root/skills"

errors=0
err() { echo "  - [$1] $2" >&2; errors=$((errors + 1)); }

if (( $# > 0 )); then skills=("$@"); else skills=(*/); fi

for s in "${skills[@]}"; do
  s="${s%/}"
  [[ -d "$s" ]] || { err "$s" "skill folder not found"; continue; }
  md="$s/SKILL.md"
  [[ -f "$md" ]] || { err "$s" "missing SKILL.md"; continue; }

  # Frontmatter: first line '---', closing '---'.
  if [[ "$(sed -n '1p' "$md")" != "---" ]]; then
    err "$s" "SKILL.md must start with '---' frontmatter"; continue
  fi
  fm="$(awk 'NR==1{next} /^---[[:space:]]*$/{exit} {print}' "$md")"
  [[ -n "$fm" ]] || { err "$s" "empty or unterminated frontmatter"; continue; }

  name="$(echo "$fm" | sed -n 's/^name:[[:space:]]*//p' | head -1)"
  desc="$(echo "$fm" | sed -n 's/^description:[[:space:]]*//p' | head -1)"
  [[ -n "$name" ]] || err "$s" "frontmatter missing 'name'"
  [[ -n "$desc" ]] || err "$s" "frontmatter missing 'description'"
  [[ -z "$name" || "$name" == "$s" ]] || err "$s" "name '$name' does not match folder '$s'"
  [[ "$s" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || err "$s" "folder name must be kebab-case"

  # Self-containment: no paths escaping the skill folder.
  if grep -rnE '(\.\./|(^|[^A-Za-z0-9_.])(skills/[a-z0-9-]+/|templates/github|rules/))' "$s" \
      --include='*.md' --include='*.sh' 2>/dev/null \
      | grep -vE "(^|[^A-Za-z0-9_.])skills/$s/" | grep -E '\.\./|rules/|templates/github|skills/[a-z0-9-]+/' >/dev/null; then
    err "$s" "references a path outside the skill folder (skills must be self-contained)"
  fi

  # Referenced files exist: `references/x`, `scripts/x`, `templates/x` in markdown.
  while IFS= read -r ref; do
    [[ -e "$s/$ref" ]] || err "$s" "referenced file not found: $ref"
  done < <(grep -rhoE '(references|scripts|templates)/[A-Za-z0-9._-]+\.[A-Za-z0-9]+' "$s" --include='*.md' | sort -u)

  # Scripts must be executable.
  while IFS= read -r sh; do
    [[ -x "$sh" ]] || err "$s" "script not executable: $sh"
  done < <(find "$s/scripts" -name '*.sh' 2>/dev/null)
done

if (( errors > 0 )); then
  echo "validate-skills FAILED: ${errors} problem(s)." >&2
  exit 1
fi
echo "validate-skills OK" >&2
