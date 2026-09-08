#!/usr/bin/env bash
# ============================================================================
# Trellis — sync.sh: optional git commit (+ pull/push) for a notebook
# ============================================================================
# Usage:
#   scripts/sync.sh                                commit with a dated default message
#   scripts/sync.sh "review: W7 weekly review"     commit with this message
#   scripts/sync.sh --notebook /path/to/nb [msg]   target a specific notebook
#   scripts/sync.sh --help
#
# Behaviour: cd to the notebook root (the directory containing mentors/ —
# found from --notebook, then the current directory upwards, then Trellis's
# ../my-notebook default), git add -A, commit, then pull --rebase --autostash
# and push ONLY if a remote exists. Never fails the caller: any git problem
# prints one line and exits 0. Sync is optional and never blocks a session
# (FIRST_PRINCIPLES P4/P5); no protocol depends on it.
# ============================================================================
set -uo pipefail

NOTEBOOK=""; MSG=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --notebook) NOTEBOOK="$2"; shift 2 ;;
    -h|--help) sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) MSG="$1"; shift ;;
  esac
done
say() { echo "[sync] $*"; }

# --- locate the notebook root: nearest ancestor containing mentors/ ----------
find_root() { local d="$1"; while [[ -n "$d" && "$d" != "/" ]]; do [[ -d "$d/mentors" ]] && { echo "$d"; return 0; }; d="$(dirname "$d")"; done; return 1; }
FRAMEWORK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ROOT="$(find_root "${NOTEBOOK:-$PWD}")" || ROOT="$(find_root "$FRAMEWORK_ROOT/../my-notebook" 2>/dev/null)" \
  || { say "no notebook root found (no mentors/ directory at or above ${NOTEBOOK:-$PWD}) — nothing synced"; exit 0; }
cd "$ROOT" || { say "cannot cd to $ROOT — nothing synced"; exit 0; }
git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || { say "$ROOT is not a git repo — run 'git init' there if you want version control; nothing synced"; exit 0; }

# --- stage + commit ----------------------------------------------------------
git add -A 2>/dev/null || { say "git add failed — nothing synced"; exit 0; }
if git diff --cached --quiet; then
  say "nothing to commit"
else
  [[ -n "$MSG" ]] || MSG="sync: $(date '+%Y-%m-%d %H:%M')"
  if git commit -q -m "$MSG" 2>/dev/null; then say "committed: $MSG"; else say "commit failed (check git user.name/user.email) — changes left staged"; exit 0; fi
fi

# --- pull --rebase + push, only if a remote exists ---------------------------
if git remote 2>/dev/null | grep -q .; then
  git pull --rebase --autostash -q 2>/dev/null || say "pull --rebase failed — commit kept locally; resolve manually"
  if git push -q 2>/dev/null; then say "pushed"; else say "push failed — commit kept locally; the next sync retries"; fi
else
  say "no remote configured — commit kept locally"
fi
exit 0
