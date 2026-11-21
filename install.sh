#!/usr/bin/env bash
# skillstack installer.
# Installs skills into <base>/.agents/skills/<name> and symlinks them into the
# agent folders you choose (.claude, .codex, .cursor, .gemini).
set -euo pipefail

REPO="${SKILLSTACK_REPO:-SebastianUrdaneguiBisalaya/skillstack}"
ALL_AGENTS="claude codex cursor gemini"
SRC=""; TMP=""

usage() {
  cat <<'EOF'
Usage: ./install.sh [options] [skill ...]

Skills:
  <name> ...        install the named skills
  --all             install every skill
  --list            list available skills and exit
  (none)            choose interactively

Agents (.agents is always created):
  --agents LIST     comma-separated: claude,codex,cursor,gemini or "all"
                    (default: choose interactively, or "claude" when not a TTY)

Scope:
  --project         install into the current directory (default)
  --global          install into $HOME
  --target DIR      install into DIR

Version (when run without a local clone, e.g. via curl):
  --version TAG     install a specific tag (default: latest tag, else main)

Other:
  --uninstall       remove the selected skills (from .agents and agent folders)
  -h, --help        show this help
EOF
}

# ---------- output ----------
use_color() { [[ -t 1 && -z "${NO_COLOR:-}" ]]; }

banner() {
  local w="" r=""
  if use_color; then w=$'\033[1;37m'; r=$'\033[0m'; fi
  printf '%s' "$w"
  cat <<'EOF'
     _    _ _ _     _             _
 ___| | _(_) | |___| |_ __ _  ___| | __
/ __| |/ / | | / __| __/ _` |/ __| |/ /
\__ \   <| | | \__ \ || (_| | (__|   <
|___/_|\_\_|_|_|___/\__\__,_|\___|_|\_\
EOF
  printf '%s\n' "$r"
}

die() { echo "error: $*" >&2; exit 1; }
info() { echo "  $*"; }

# ---------- discovery ----------
list_skills() {
  local d
  for d in "$SRC"/skills/*/; do
    [[ -f "${d}SKILL.md" ]] && basename "$d"
  done
}

describe() {
  sed -n 's/^description:[[:space:]]*//p' "$SRC/skills/$1/SKILL.md" | head -1 | cut -c1-80
}

# ---------- selection helpers ----------
# pick "<prompt>" item1 item2 ... -> prints chosen items (space separated)
# Accepts numbers separated by spaces/commas, or "a" for all.
pick() {
  local prompt="$1"; shift
  local items=("$@") answer n out=()
  read -r -p "$prompt" answer </dev/tty || answer=""
  answer="${answer//,/ }"
  if [[ "$answer" == "a" || "$answer" == "all" ]]; then
    echo "${items[*]}"; return
  fi
  for n in $answer; do
    [[ "$n" =~ ^[0-9]+$ ]] && (( n >= 1 && n <= ${#items[@]} )) || die "invalid choice: $n"
    out+=("${items[$((n - 1))]}")
  done
  echo "${out[*]:-}"
}

# ---------- options ----------
skills=(); agents=""; want_all=0; do_list=0; uninstall=0; base="$PWD"; version=""

while (( $# )); do
  case "$1" in
    --all) want_all=1 ;;
    --list) do_list=1 ;;
    --agents) shift; [[ $# -gt 0 ]] || die "--agents needs a value"; agents="$1" ;;
    --project) base="$PWD" ;;
    --global) base="$HOME" ;;
    --target) shift; [[ $# -gt 0 ]] || die "--target needs a directory"; base="$1" ;;
    --version) shift; [[ $# -gt 0 ]] || die "--version needs a tag"; version="$1" ;;
    --uninstall) uninstall=1 ;;
    -h|--help) usage; exit 0 ;;
    -*) die "unknown option: $1 (see --help)" ;;
    *) skills+=("$1") ;;
  esac
  shift
done

cleanup() { [[ -n "$TMP" ]] && rm -rf "$TMP"; return 0; }
trap cleanup EXIT

# Use the local checkout when skills/ sits next to this script; otherwise download.
script="${BASH_SOURCE[0]:-}"
if [[ -n "$script" && -f "$script" && -d "$(dirname "$script")/skills" ]]; then
  SRC="$(cd "$(dirname "$script")" && pwd)"
  ref="local"
else
  command -v curl >/dev/null || die "curl is required to download skillstack"
  command -v tar >/dev/null || die "tar is required to download skillstack"
  ref="$version"
  if [[ -z "$ref" ]]; then
    ref=""
    if command -v git >/dev/null; then
      ref="$(git ls-remote --tags --refs "https://github.com/$REPO.git" 2>/dev/null \
        | sed 's#.*refs/tags/##' | sort -V | tail -1 || true)"
    fi
    [[ -n "$ref" ]] || ref="main"
  fi
  url="${SKILLSTACK_ARCHIVE_URL:-https://codeload.github.com/$REPO/tar.gz/$ref}"
  TMP="$(mktemp -d)"
  curl -fsSL "$url" | tar -xz -C "$TMP" --strip-components=1 \
    || die "could not download skillstack ($ref) from $url"
  SRC="$TMP"
fi

available=()
while IFS= read -r s; do available+=("$s"); done < <(list_skills)
(( ${#available[@]} )) || die "no skills found in $SRC/skills"

banner
echo "skillstack: $ref"

if (( do_list )); then
  echo "Available skills:"
  for s in "${available[@]}"; do printf '  %-16s %s\n' "$s" "$(describe "$s")"; done
  exit 0
fi

# Interactive when stdout is a terminal and /dev/tty is usable (also works when piped from curl).
interactive=0
if [[ -t 1 ]] && { : </dev/tty; } 2>/dev/null; then interactive=1; fi

# ---------- choose skills ----------
if (( want_all )); then
  skills=("${available[@]}")
elif (( ${#skills[@]} == 0 )); then
  (( interactive )) || die "no skills given; pass names, --all, or run in a terminal"
  echo "Skills:"
  i=1; for s in "${available[@]}"; do printf '  %d) %-16s %s\n' "$i" "$s" "$(describe "$s")"; i=$((i + 1)); done
  read -r -a skills <<<"$(pick "Select skills (numbers, or 'a' for all): " "${available[@]}")"
fi
(( ${#skills[@]} )) || die "no skills selected"
for s in "${skills[@]}"; do
  [[ -f "$SRC/skills/$s/SKILL.md" ]] || die "unknown skill: $s (use --list)"
done

# ---------- choose agents ----------
if [[ -z "$agents" ]]; then
  if (( interactive )); then
    echo; echo "Agents (.agents is always created):"
    i=1; for a in $ALL_AGENTS; do printf '  %d) %s\n' "$i" ".$a"; i=$((i + 1)); done
    # shellcheck disable=SC2086
    agents="$(pick "Select agents (numbers, 'a' for all, empty for none): " $ALL_AGENTS)"
  else
    agents="claude"
  fi
fi
agents="${agents//,/ }"
[[ "$agents" == "all" ]] && agents="$ALL_AGENTS"
for a in $agents; do
  case " $ALL_AGENTS " in *" $a "*) ;; *) die "unknown agent: $a (valid: $ALL_AGENTS)" ;; esac
done

# ---------- act ----------
echo
echo "Target: $base"
mkdir -p "$base"

if (( uninstall )); then
  for s in "${skills[@]}"; do
    for a in $ALL_AGENTS; do
      link="$base/.$a/skills/$s"
      if [[ -L "$link" ]]; then rm "$link"; info "removed .$a/skills/$s"; fi
    done
    if [[ -d "$base/.agents/skills/$s" ]]; then
      rm -rf "$base/.agents/skills/$s"; info "removed .agents/skills/$s"
    fi
  done
  echo "Done."; exit 0
fi

for s in "${skills[@]}"; do
  dest="$base/.agents/skills/$s"
  mkdir -p "$base/.agents/skills"
  rm -rf "$dest"
  cp -R "$SRC/skills/$s" "$dest"
  find "$dest" -name .gitkeep -delete
  info "installed .agents/skills/$s"

  for a in $agents; do
    dir="$base/.$a/skills"
    link="$dir/$s"
    mkdir -p "$dir"
    if [[ -e "$link" && ! -L "$link" ]]; then
      echo "  skipped .$a/skills/$s: exists and is not a symlink" >&2
      continue
    fi
    rm -f "$link"
    ln -s "../../.agents/skills/$s" "$link"
    info "linked   .$a/skills/$s -> .agents/skills/$s"
  done
done
echo "Done."
