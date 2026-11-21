#!/usr/bin/env bash
# Validates a commit message file: type(scope): subject
# Usage: check-commit-msg.sh <message-file>
set -euo pipefail

file="${1:-}"
if [[ -z "$file" || ! -f "$file" ]]; then
  echo "usage: $0 <commit-message-file>" >&2
  exit 2
fi

header="$(grep -v '^#' "$file" | sed -n '1p')"

# Allow git-generated merge commits.
if [[ "$header" =~ ^Merge\  ]]; then
  exit 0
fi

types="feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert"
pattern="^(${types})(\([a-z0-9._/-]+\))?!?: [^[:space:]].*[^.]$"

fail() {
  echo "commit message rejected: $1" >&2
  echo "  header: \"$header\"" >&2
  echo "  expected: type(scope): subject" >&2
  echo "  types: ${types//|/, }" >&2
  echo "  rules: imperative lowercase subject, no trailing period, header <= 72 chars" >&2
  exit 1
}

[[ -n "$header" ]] || fail "empty message"
[[ ${#header} -le 72 ]] || fail "header is ${#header} chars (max 72)"
[[ "$header" =~ $pattern ]] || fail "header does not match the Conventional Commits format"

subject="${header#*: }"
[[ "$subject" =~ ^[A-Z] ]] && fail "subject must start in lowercase"

exit 0
