#!/usr/bin/env bash
# Rejects agent attribution in a commit message, issue body or PR body.
# Usage: check-no-coauthor.sh <file>   (or pipe text on stdin with "-")
set -euo pipefail

src="${1:--}"
if [[ "$src" == "-" ]]; then
  text="$(cat)"
elif [[ -f "$src" ]]; then
  text="$(cat "$src")"
else
  echo "usage: $0 <file|->" >&2
  exit 2
fi

pattern='co-authored-by|generated (with|by)|🤖|noreply@anthropic\.com'

if matches="$(printf '%s\n' "$text" | grep -inE "$pattern")"; then
  echo "agent attribution is not allowed (author must be the user only):" >&2
  printf '%s\n' "$matches" | sed 's/^/  line /' >&2
  echo "  fix: remove these lines." >&2
  exit 1
fi
exit 0
