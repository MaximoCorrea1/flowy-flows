#!/usr/bin/env sh
# =============================================================================
# flowy-gc.sh — Flowy SessionStart garbage-collection hook
# =============================================================================
#
# WHAT IT IS
#   A Claude Code `SessionStart` command hook. At session start Claude Code
#   exports two env vars:
#
#     CLAUDE_PROJECT_DIR   real project root
#     CLAUDE_PLUGIN_ROOT   this plugin's install dir
#
#   This hook deletes state-*.json files older than FLOWY_STATE_GC_DAYS (14)
#   days from the OUT-OF-REPO state dir. It is a best-effort janitor.
#
# CONTRACT (non-negotiable)
#   * ALWAYS exits 0. NEVER blocks. On ANY error → silent no-op.
#   * NEVER deletes symlinks or follows them to delete their targets.
#   * NEVER touches a state dir that is itself a symlink.
#   * No-op when the state dir is absent.
#   * No jq / python / node — POSIX sh only.
#
# STATE DIR DERIVATION (MUST be byte-identical to flowy-inject.sh §2b)
#   CLAUDE_HOME = ${CLAUDE_PLUGIN_ROOT%/plugins/*}   (must end in /.claude)
#   PROJECT_KEY = CLAUDE_PROJECT_DIR with every non-[A-Za-z0-9] char → '_'
#   STATE_DIR   = $CLAUDE_HOME/flowy-state/$PROJECT_KEY
#
# COUPLING NOTE
#   The keep-alive `touch` that refreshes a session's state file mtime (so
#   an active long session is not GC'd after 14 days) ships in a separate,
#   gated task. 14 days is conservative for V1, so GC ships first.
#
# SHELL
#   Runs under Git Bash on Windows (NOT WSL). The repo path may contain a
#   space ("Projects VS"), so EVERY path expansion is double-quoted.
# =============================================================================

# Hard guarantee: whatever happens below, this process exits 0.
trap 'exit 0' EXIT

# Be defensive; do NOT use set -e (grep no-match returns 1 as a control signal).
set -u 2>/dev/null || true

# ---------------------------------------------------------------------------
# 1. Require CLAUDE_PROJECT_DIR and CLAUDE_PLUGIN_ROOT non-empty.
# ---------------------------------------------------------------------------
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-}"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-}"
[ -n "$PROJECT_DIR" ] || exit 0
[ -n "$PLUGIN_ROOT" ] || exit 0

# ---------------------------------------------------------------------------
# 2. Derive CLAUDE_HOME / PROJECT_KEY / STATE_DIR — EXACTLY as §2b of
#    flowy-inject.sh (same %/plugins/* strip, same */.claude guard, same tr).
# ---------------------------------------------------------------------------
CLAUDE_HOME="${PLUGIN_ROOT%/plugins/*}"
# No /plugins/ found → expansion is a no-op (equals PLUGIN_ROOT) → exit.
[ "$CLAUDE_HOME" != "$PLUGIN_ROOT" ] || exit 0
# Must resolve to a .claude home; reject any other directory shape.
case "$CLAUDE_HOME" in
  */.claude ) : ;;   # ok
  * ) exit 0 ;;      # not a .claude home → no-op
esac

# Deterministic project key: every non-[A-Za-z0-9] char → '_'.
PROJECT_KEY="$(printf '%s' "$PROJECT_DIR" | tr -c 'A-Za-z0-9' '_')"
[ -n "$PROJECT_KEY" ] || exit 0

STATE_DIR="$CLAUDE_HOME/flowy-state/$PROJECT_KEY"

# ---------------------------------------------------------------------------
# 3. Guard: STATE_DIR must exist as a real directory (not a symlink).
# ---------------------------------------------------------------------------
# Missing → no-op (nothing to clean).
[ -d "$STATE_DIR" ] || exit 0
# Symlinked dir → never follow it (a planted link could redirect GC to an
# arbitrary directory). `[ -L ]` is true even when the link target is a dir,
# so check this AFTER the `-d` test.
[ ! -L "$STATE_DIR" ] || exit 0

# ---------------------------------------------------------------------------
# 4. Load timing constants. If sourcing fails, fall back to hardcoded default.
# ---------------------------------------------------------------------------
FLOWY_STATE_GC_DAYS=14
# shellcheck source=./flowy-constants.sh
. "$(dirname "$0")/flowy-constants.sh" 2>/dev/null || FLOWY_STATE_GC_DAYS=14

# ---------------------------------------------------------------------------
# 5. Garbage-collect state-*.json files older than FLOWY_STATE_GC_DAYS days.
#    For each matching file:
#      - [ -e ] guards against globs with no matches or races.
#      - [ ! -L ] skips symlinks — never delete a link or its target.
#      - `find "$f" -mtime +N` returns non-empty if the file is older than N
#        days; if so, rm -f it.
# ---------------------------------------------------------------------------
for f in "$STATE_DIR"/state-*.json; do
  # Guard against empty glob expansion (no files match → f is the literal pattern).
  [ -e "$f" ] || continue
  # Skip symlinks — never delete a symlink target.
  [ ! -L "$f" ] || continue
  # find -mtime +N: matches files whose mtime is MORE than N days old.
  if [ -n "$(find "$f" -mtime +"$FLOWY_STATE_GC_DAYS" 2>/dev/null)" ]; then
    rm -f "$f" 2>/dev/null || true
  fi
done

# Trap guarantees exit 0; be explicit anyway.
exit 0
