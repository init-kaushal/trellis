#!/usr/bin/env bash
# ============================================================================
# Trellis — Validate a notebook's structure
# ============================================================================
# Checks for the files and folders the protocols expect, and the fold health
# of the five always-read files (+ every domain's current_focus.md): exactly
# one "## ── HISTORY" fold line, and the text above it within the byte budget
# stated in the file's own header ("≤ N KB"). Reports drift. Modifies nothing.
#
# Usage: ./scripts/validate.sh [--notebook] /path/to/notebook
# ============================================================================

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

NOTEBOOK=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --notebook) NOTEBOOK="$2"; shift 2 ;;
    -h|--help) echo "usage: $0 [--notebook] DIR"; exit 0 ;;
    -*) echo "unknown arg: $1"; exit 1 ;;
    *) NOTEBOOK="$1"; shift ;;
  esac
done

[[ -z "$NOTEBOOK" && -d "$FRAMEWORK_ROOT/../my-notebook" ]] && NOTEBOOK="$(cd "$FRAMEWORK_ROOT/../my-notebook" && pwd)"
[[ -z "$NOTEBOOK" ]] && { read -r -p "Path to notebook: " NOTEBOOK; }
[[ -d "$NOTEBOOK" ]] || { echo "not a directory: $NOTEBOOK"; exit 1; }

c_red=$'\033[31m'; c_green=$'\033[32m'; c_yellow=$'\033[33m'; c_reset=$'\033[0m'
fails=0; warns=0
FOLD='^## ── HISTORY'

check_file() {
  if [[ -f "$NOTEBOOK/$1" ]]; then
    printf "%s✓%s %s\n" "$c_green" "$c_reset" "$1"
  else
    printf "%s✗%s %s (missing)\n" "$c_red" "$c_reset" "$1"; fails=$((fails+1))
  fi
}

check_dir() {
  if [[ -d "$NOTEBOOK/$1" ]]; then
    printf "%s✓%s %s/\n" "$c_green" "$c_reset" "$1"
  else
    printf "%s✗%s %s/ (missing)\n" "$c_red" "$c_reset" "$1"; fails=$((fails+1))
  fi
}

warn_if_unsub() {
  if grep -l '{{[A-Z_]*}}' "$NOTEBOOK/$1" 2>/dev/null >/dev/null; then
    printf "%s⚠%s %s contains unsubstituted {{PLACEHOLDERS}}\n" "$c_yellow" "$c_reset" "$1"; warns=$((warns+1))
  fi
}

# check_fold <relative path>
#   FAIL unless the file has exactly one fold line.
#   WARN if the bytes above the fold exceed the "≤ N KB" budget in the header.
check_fold() {
  local f="$1" path="$NOTEBOOK/$1" n top budget
  [[ -f "$path" ]] || return 0   # a missing file is already reported by check_file
  n=$(grep -c "$FOLD" "$path")
  if (( n != 1 )); then
    printf "%s✗%s %s has %d fold lines (expected exactly one '## ── HISTORY …' line)\n" "$c_red" "$c_reset" "$f" "$n"
    fails=$((fails+1)); return
  fi
  top=$(sed -n "1,/$FOLD/p" "$path" | wc -c | tr -d ' ')
  budget=$(grep -o '≤ *[0-9][0-9]* *KB' "$path" | head -1 | grep -o '[0-9][0-9]*')
  if [[ -n "$budget" ]] && (( top > budget * 1024 )); then
    printf "%s⚠%s %s: %d bytes above the fold, over its stated budget of %s KB\n" "$c_yellow" "$c_reset" "$f" "$top" "$budget"
    warns=$((warns+1))
  elif [[ -n "$budget" ]]; then
    printf "%s✓%s %s fold ok (%d bytes above the fold, budget %s KB)\n" "$c_green" "$c_reset" "$f" "$top" "$budget"
  else
    printf "%s⚠%s %s fold ok (%d bytes above the fold) but its header states no '≤ N KB' budget\n" "$c_yellow" "$c_reset" "$f" "$top"
    warns=$((warns+1))
  fi
}

echo "Validating notebook at: $NOTEBOOK"
echo "---"

# Top-level
for f in CLAUDE.md CONFIG.md README.md; do check_file "$f"; warn_if_unsub "$f"; done

# Mentors (shared files)
for f in mentors/MEMORY.md mentors/profile.md mentors/season_current.md mentors/coordinator_state.md mentors/cross_domain.md; do
  check_file "$f"; warn_if_unsub "$f"
done

# Framework copies
for f in framework/FIRST_PRINCIPLES.md framework/PROTOCOLS.md framework/WIKI_BRIDGE.md; do
  check_file "$f"
done

# Skills (the two high-frequency procedures, loaded verbatim on trigger) + companions
for f in .claude/skills/weekly-review/SKILL.md .claude/skills/weekly-review/mentor_prompt.md .claude/skills/domain-session/SKILL.md; do
  check_file "$f"; warn_if_unsub "$f"
done

# Fold health — the always-read shared files
echo "---"
echo "fold check (exactly one '## ── HISTORY' line; top half within its stated budget)"
for f in mentors/MEMORY.md mentors/profile.md mentors/coordinator_state.md mentors/season_current.md; do
  check_fold "$f"
done

# Per-domain
for d in "$NOTEBOOK"/mentors/*/; do
  [[ -d "$d" ]] || continue
  dname="$(basename "$d")"
  [[ "$dname" =~ ^(_template|coordinator_history|profile_history)$ ]] && continue
  echo "---"
  echo "domain: $dname"
  for f in README.md current_focus.md done_topics.md intel.md curriculum.md log.md; do
    check_file "mentors/$dname/$f"
  done
  check_dir "mentors/$dname/sessions"
  check_dir "mentors/$dname/archive"
  check_fold "mentors/$dname/current_focus.md"
done

echo "---"
if (( fails == 0 && warns == 0 )); then
  printf "%sAll checks passed.%s\n" "$c_green" "$c_reset"
  exit 0
elif (( fails == 0 )); then
  printf "%s%d warning(s).%s\n" "$c_yellow" "$warns" "$c_reset"; exit 0
else
  printf "%s%d failure(s), %d warning(s).%s\n" "$c_red" "$fails" "$warns" "$c_reset"; exit 1
fi
