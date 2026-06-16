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
# 2. Derive the state ROOT (<claude-home>/flowy-state) via the SHARED helper.
#    The GC sweeps EVERY per-project dir under it (not a single key), so it
#    (a) needs NO project-key derivation -> zero drift vs the hook/activator,
#    and (b) self-heals legacy state dirs left under any pre-canonicalization
#    key form (Bug E orphans). Empty output -> no-op (fail-loud, never block).
#    A missing/unsourceable helper also no-ops.
# ---------------------------------------------------------------------------
. "$(dirname "$0")/flowy-paths.sh" 2>/dev/null || exit 0
STATE_ROOT="$(flowy_state_root "$PLUGIN_ROOT")"
[ -n "$STATE_ROOT" ] || exit 0

# ---------------------------------------------------------------------------
# 3. Guard: the state ROOT must exist as a real directory (not a symlink).
# ---------------------------------------------------------------------------
[ -d "$STATE_ROOT" ] || exit 0      # absent -> nothing to clean
[ ! -L "$STATE_ROOT" ] || exit 0    # symlinked root -> never follow it

# ---------------------------------------------------------------------------
# 4. Load timing constants. If sourcing fails, fall back to hardcoded default.
# ---------------------------------------------------------------------------
FLOWY_STATE_GC_DAYS=14
# shellcheck source=./flowy-constants.sh
. "$(dirname "$0")/flowy-constants.sh" 2>/dev/null || FLOWY_STATE_GC_DAYS=14

# ---------------------------------------------------------------------------
# 5. Sweep EVERY per-project dir under the state root, GC'ing state-*.json
#    older than FLOWY_STATE_GC_DAYS. Sweeping all dirs (not one key) makes the
#    GC key-agnostic (no drift) and self-heals legacy/divergent-key orphans.
#      - skip a symlinked project dir (never follow a planted link).
#      - per file: [ -e ] guards empty globs; [ ! -L ] skips symlinks;
#        `find -mtime +N` matches files MORE than N days old.
# ---------------------------------------------------------------------------
for _dir in "$STATE_ROOT"/*/; do
  # Empty glob -> the literal pattern; `[ -d ]` rejects it.
  [ -d "$_dir" ] || continue
  # Skip a symlinked project-state dir (strip trailing slash for the -L test).
  [ ! -L "${_dir%/}" ] || continue
  for f in "$_dir"state-*.json; do
    [ -e "$f" ] || continue
    [ ! -L "$f" ] || continue
    if [ -n "$(find "$f" -mtime +"$FLOWY_STATE_GC_DAYS" 2>/dev/null)" ]; then
      rm -f "$f" 2>/dev/null || true
    fi
  done
done

# Trap guarantees exit 0; be explicit anyway.
exit 0
