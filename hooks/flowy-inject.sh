#!/usr/bin/env sh
# =============================================================================
# flowy-inject.sh — Flowy enforcement core (UserPromptSubmit hook)
# =============================================================================
#
# WHAT IT IS
#   A Claude Code `UserPromptSubmit` command hook. On every user prompt, Claude
#   Code pipes a flat JSON object on stdin and exports two env vars:
#
#     stdin JSON   { "session_id": "<id>", "prompt": "<text>", ... }
#     env          CLAUDE_PROJECT_DIR   real project root
#                  CLAUDE_PLUGIN_ROOT   this plugin's install dir
#
#   If a Flowy Flow is active for this session, the hook prints a loud routing
#   banner to stdout. On exit 0, Claude Code injects that stdout into the
#   agent's context — which is how we make routing mandatory.
#
# CONTRACT (non-negotiable)
#   * FAIL-LOUD, NEVER FAIL-CLOSED. The hook ALWAYS exits 0. It NEVER blocks
#     (never exits 2). On ANY error it degrades to a silent no-op. This is the
#     common case: in every normal repo with no Flow active, this script must
#     read stdin, find no state file, and exit 0 with empty stdout.
#   * Emit ONLY the intended banner/warning to stdout. Nothing stray.
#
# STATE FILE SHAPE — schema "flowy-state-v1"
#   Written by the activator unit to the OUT-OF-REPO state dir (see RR2 below):
#     <CLAUDE_HOME>/flowy-state/<project-key>/state-<session_id>.json
#   (or .../state-PENDING.json before a session_id is known). The dir is derived
#   by the shared helper hooks/flowy-paths.sh (flowy_state_dir); see that file for
#   the canonical, path-form-independent key algorithm (0.6.2+).
#
#     {
#       "schema": "flowy-state-v1",
#       "sessionId": "<id>",
#       "activeFlows": [
#         { "name": "superpowers-flow", "flowRef": "flows/superpowers-flow/FLOW.md", "location": "plugin" }
#       ]
#     }
#
#   "location" (optional, RR1): "plugin" (default/absent) resolves the FLOW.md
#   under $CLAUDE_PLUGIN_ROOT; "project" resolves it under
#   $CLAUDE_PROJECT_DIR/.flowy/flows/<name>/FLOW.md. Parsed positionally with name.
#
#   Deliberately flat so we can parse it with grep/sed and NO jq/python/node.
#   The parser is LINE-ORIENTED: it requires each `"name": "..."` and
#   `"flowRef": "..."` key-value pair to appear on a single line. This holds
#   for minified single-line JSON AND for standard pretty-printed JSON (one
#   key per line). It breaks only if a key is split across lines or a value
#   contains an escaped quote (`\"`) — both of which the activator must avoid.
#   Parsing rules:
#     * "active" = file exists AND contains "activeFlows" AND >=1 "name": entry.
#     * `flowRef` is a CLAUDE_PLUGIN_ROOT-relative path (version-agnostic, NOT
#       an absolute cache path). The live FLOW.md is "$CLAUDE_PLUGIN_ROOT"/<ref>.
#     * We read names and flowRefs positionally: the activator writes them in
#       lockstep order (name then flowRef, one pair per array element), so the
#       Nth name pairs with the Nth flowRef.
#
# RESOLUTION + AUTO-REPAIR (per flow)
#   location "project" (RR1):
#     P. Resolve "$CLAUDE_PROJECT_DIR/.flowy/flows/<name>/FLOW.md" ONLY. No plugin
#        fallback (explicit location must not be silently rescued by a bundled
#        same-named flow). Else → corrupt.
#   location "plugin" / absent:
#     1. Try "$CLAUDE_PLUGIN_ROOT"/<flowRef>. If it exists → live.
#     2. Else recompute "$CLAUDE_PLUGIN_ROOT"/flows/<name>/FLOW.md. If it exists
#        → live (stale flowRef auto-repaired).
#     3. Else → corrupt (active in state, FLOW.md unresolvable) → loud warning.
#   In ALL cases (RR3) the RESOLVED FLOW.md is rejected if it is a symlink
#   (`[ ! -L ]`) — a planted link must never read an arbitrary file into context.
#
# SECURITY
#   session_id is sanitized against ^[A-Za-z0-9_-]{1,128}$ before it is ever
#   interpolated into a path. Anything else (traversal, metacharacters, empty)
#   → no-op. We never build a path from an untrusted id.
#
# HARDENING (v0.4.1 — ce:review findings)
#   (1) RACE-SAFE PENDING CLAIM. The activator still writes a single shared
#       state-PENDING.json (it cannot know the real session_id — only this hook
#       can). The OLD claim was a check-then-act: `[ ! -f STATE ] && mv PENDING
#       STATE`. Two concurrent sessions in the same dir could both pass the
#       check and race on the single PENDING — one session's flow then silently
#       fails to enforce, or PENDING is claimed by the wrong session.
#       We SERIALIZE the claim with an atomic `mkdir` lock (.flowy/.claim.lock):
#       mkdir is atomic on POSIX (and on networked FS), so exactly one concurrent
#       process wins. The winner does the `mv` and rmdir's the lock; losers skip
#       claiming this turn (a no-op — they retry next prompt, or read their own
#       state-<id>.json if it already exists). A held/stale lock NEVER wedges
#       enforcement: if mkdir fails we simply skip the claim this turn, and the
#       worst case is the flow activates one turn later (fail-loud, never block).
#       The lock is rmdir'd in the same branch that created it AND defensively on
#       the EXIT trap, so a crash mid-claim cannot leave it held forever for the
#       winning process. (A lock left by a hard-killed process is tolerated: the
#       next turn skips claiming once, then a manual /flowy re-activate clears it;
#       we deliberately avoid non-portable POSIX `stat` for stale-age detection.)
#       WHY mkdir over bare atomic mv: same-FS `mv` IS atomic, but the guarding
#       `[ ! -f STATE ]` test before it is not — the lock closes that window.
#   (2) BOUNDED STDIN. We read only the first 32KB of stdin (head -c 32768) instead
#       of slurping an unbounded prompt every turn. session_id sits near the top
#       of Claude Code's JSON, so 32KB contains it comfortably. TRADEOFF: if a
#       future Claude Code build emits the prompt BEFORE session_id and the
#       prompt exceeds 32KB, session_id extraction fails → no-op. That is rare and
#       safe (fail-loud degrades to no enforcement that turn, never a block).
#       32KB safely covers a large prompt preamble before session_id with
#       negligible read cost; if Claude Code ever serializes a >32KB prompt BEFORE
#       session_id, extraction no-ops (safe, rare).
#   (3) BOUNDED STATE FILE. Before `cat`-ing a state file we cap it at 64KB
#       (wc -c). A legit flowy-state-v1 file is well under 1KB; a pathological or
#       corrupt giant file can no longer stall every prompt. Over the cap → no-op.
#   (4) SYMLINK REJECTION. `[ -f ... ]` follows symlinks, so an attacker-planted
#       symlink at the state (or PENDING) path could read an arbitrary file into
#       the agent's context. We add `[ ! -L ... ]`: a symlinked state file → no-op;
#       a symlinked PENDING → claim skipped.
#   (5) flowRef CHARSET ALLOWLIST. Before using a flowRef in a path test we drop
#       any ref containing a char outside [A-Za-z0-9_./-] (so spaces, backslashes,
#       shell metachars, `$(...)`, single-dot oddities are neutered). A dropped
#       ref falls through to name-based auto-repair, exactly like a stale ref.
#   (6) CORRUPT NAMES: newline-separated accumulation + IFS= read -r iteration
#       (dropped the fragile IFS=', ' split that mangled names with dots).
#
# SHELL
#   Runs under Git Bash on Windows (NOT WSL). The repo path contains a space
#   ("Projects VS"), so EVERY path expansion is double-quoted.
# =============================================================================

# --- Hard guarantee: whatever happens below, this process exits 0. ----------
# A trap on EXIT forces status 0 even if an unexpected error escapes. We never
# block the user's prompt. CLAIM_LOCK is set only while THIS process holds the
# claim lock; the trap rmdir's it defensively so a crash mid-claim cannot leave
# our own lock held. (rmdir of an empty string or non-dir is a harmless no-op.)
CLAIM_LOCK=""
trap 'if [ -n "$CLAIM_LOCK" ]; then rmdir "$CLAIM_LOCK" 2>/dev/null || true; fi; exit 0' EXIT

# Be defensive but do NOT use `set -e` — a non-zero from grep (no match) is a
# normal control-flow signal here, not a failure. We handle failures explicitly.
set -u 2>/dev/null || true

# ---------------------------------------------------------------------------
# 1. Read a BOUNDED prefix of stdin (Fix 2). The session_id sits near the top
#    of Claude Code's JSON, so the first 32KB contains it comfortably even with a
#    large prompt. We do NOT slurp an unbounded prompt every turn. TRADEOFF: if
#    a future build emits the prompt before session_id and the prompt > 32KB,
#    extraction fails → no-op (rare + safe). 32KB safely covers a large prompt
#    preamble before session_id with negligible read cost. If stdin is
#    closed/empty, STDIN stays empty.
# ---------------------------------------------------------------------------
STDIN="$(head -c 32768 2>/dev/null || true)"

# Env vars must be present and non-empty; otherwise we cannot resolve paths.
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-}"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-}"
[ -n "$PROJECT_DIR" ] || exit 0
[ -n "$PLUGIN_ROOT" ] || exit 0

# ---------------------------------------------------------------------------
# 2. Extract + sanitize session_id from the flat JSON.
#    Grep the first  "session_id" : "<value>"  occurrence and capture <value>.
#    We do NOT decode JSON escapes — a legitimate session_id has none, and the
#    allowlist below rejects anything that would have needed decoding.
# ---------------------------------------------------------------------------
SESSION_ID="$(
  printf '%s' "$STDIN" \
    | grep -o '"session_id"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | head -n 1 \
    | sed 's/.*:[[:space:]]*"//; s/"$//' \
    | tr -d '\r'
)"

# Allowlist: 1-128 chars of [A-Za-z0-9_-]. Reject everything else (traversal,
# metacharacters, empty). `expr` keeps this POSIX and avoids bashism creep.
is_safe_id() {
  # $1 = candidate. Returns 0 if it matches the allowlist exactly.
  case "$1" in
    '' ) return 1 ;;
  esac
  # Length guard (<=128).
  if [ "${#1}" -gt 128 ]; then
    return 1
  fi
  # Character allowlist: anything outside [A-Za-z0-9_-] disqualifies.
  case "$1" in
    *[!A-Za-z0-9_-]* ) return 1 ;;
    * ) return 0 ;;
  esac
}

is_safe_id "$SESSION_ID" || exit 0
# From here, SESSION_ID is path-safe.

# ---------------------------------------------------------------------------
# 2b. Derive the OUT-OF-REPO state dir (RR2 security fix) via the SHARED helper.
#     State must NEVER be read from inside the project repo (a cloned repo could
#     ship a committed $PROJECT_DIR/.flowy/state-*.json + flows/evil/FLOW.md and
#     the hook would otherwise claim it). flowy-paths.sh anchors state under the
#     user's Claude home (<...>/.claude/flowy-state/<project-key>) derived from
#     CLAUDE_PLUGIN_ROOT, HARD-REQUIRES a /.claude home, and computes a CANONICAL
#     project-key so the hook, GC, and activator agree byte-for-byte regardless
#     of CLAUDE_PROJECT_DIR path form (Windows E:\ vs Git-Bash /e/ — Bug E). It is
#     the SINGLE source of truth; empty output = a no-op condition (no /plugins/,
#     not a .claude home, empty key) → exit 0 (fail-loud, never block). A
#     missing/unsourceable helper also no-ops.
# ---------------------------------------------------------------------------
. "$(dirname "$0")/flowy-paths.sh" 2>/dev/null || exit 0
STATE_DIR="$(flowy_state_dir "$PROJECT_DIR" "$PLUGIN_ROOT")"
[ -n "$STATE_DIR" ] || exit 0
mkdir -p "$STATE_DIR" 2>/dev/null || true

# (A) Source timing constants. Provides FLOWY_PENDING_TTL_SECONDS (default 120).
# The 2>/dev/null suppresses "file not found" on clean installs; the fallback
# ensures the variable is always set even if the constants file is absent.
. "$(dirname "$0")/flowy-constants.sh" 2>/dev/null || FLOWY_PENDING_TTL_SECONDS=120

# Project-local flow CONTENT root (inert without an out-of-repo state pointer).
# Only used to RESOLVE FLOW.md for entries marked "location":"project".
PROJECT_FLOWS_DIR="$PROJECT_DIR/.flowy/flows"

# ---------------------------------------------------------------------------
# 3. Claim a PENDING activation, RACE-SAFE (Fix 1). If state-PENDING.json exists
#    and we have a safe id, rename it to state-<id>.json — but serialize the
#    check-then-mv behind an atomic mkdir lock so two concurrent sessions in the
#    same dir can't both claim the single shared PENDING.
#
#    Lock protocol:
#      * `mkdir .claim.lock` is atomic on POSIX; exactly one concurrent process
#        succeeds. The winner sets CLAIM_LOCK (so the EXIT trap also cleans it),
#        performs the guarded mv, then rmdir's the lock immediately.
#      * Losers (mkdir fails) SKIP claiming this turn. That is a safe no-op —
#        they retry next prompt, or read their own state-<id>.json if present.
#      * A held/stale lock therefore never wedges enforcement; worst case the
#        flow activates one turn later. We never block.
#
#    Symlink guard (Fix 4): a symlinked PENDING is never claimed — we'd otherwise
#    mv an attacker-controlled link target into a session state path.
# ---------------------------------------------------------------------------
PENDING="$STATE_DIR/state-PENDING.json"
STATE="$STATE_DIR/state-$SESSION_ID.json"

if [ -f "$PENDING" ] && [ ! -L "$PENDING" ]; then
  # Acquire the claim lock atomically. Only the process whose mkdir succeeds
  # proceeds; everyone else skips claiming this turn.
  if mkdir "$STATE_DIR/.claim.lock" 2>/dev/null; then
    CLAIM_LOCK="$STATE_DIR/.claim.lock"
    # Re-check inside the lock (the winner may have just created STATE; and the
    # PENDING may have been claimed/removed between our outer test and the lock).
    if [ -f "$PENDING" ] && [ ! -L "$PENDING" ]; then
      # (B) TTL freshness gate. Parse createdAtEpoch from the PENDING file
      # (line-oriented grep/sed, same pattern as NAMES/REFS parsing above).
      createdAtEpoch="$(
        grep -o '"createdAtEpoch"[[:space:]]*:[[:space:]]*[0-9][0-9]*' "$PENDING" \
          | head -n 1 \
          | sed 's/.*:[[:space:]]*//' \
          | tr -d '[:space:]'
      )"
      now="$(date +%s 2>/dev/null)"

      # Fail CLOSED: if `now` is empty or contains any non-digit, treat as stale.
      # POSIX case matching: (*[!0-9]*|'') catches empty string and non-integers.
      case "$now" in
        *[!0-9]*|'' ) now="" ;;
      esac

      # Determine freshness:
      #   FRESH = createdAtEpoch is all-digits AND now is valid AND
      #           (now - createdAtEpoch) <= FLOWY_PENDING_TTL_SECONDS.
      FRESH=0
      if [ -n "$createdAtEpoch" ] && [ -n "$now" ]; then
        case "$createdAtEpoch" in
          *[!0-9]*|'' ) : ;;  # non-integer epoch → not fresh
          * )
            age=$((now - createdAtEpoch))
            if [ "$age" -le "$FLOWY_PENDING_TTL_SECONDS" ] && [ "$age" -ge 0 ]; then
              FRESH=1
            fi
            ;;
        esac
      fi

      if [ "$FRESH" -eq 1 ]; then
        # FRESH PENDING: claim it if STATE doesn't exist yet.
        if [ ! -f "$STATE" ]; then
          mv "$PENDING" "$STATE" 2>/dev/null || true
        fi
        # If STATE already exists: leave PENDING untouched (fresh orphan; it will
        # be deleted once it goes stale on the next prompt).
      else
        # STALE (or un-stamped, or bad `now`): self-heal by deleting. A leftover
        # PENDING from a prior session can no longer be claimed by an unrelated
        # session after TTL has elapsed.
        rm -f "$PENDING" 2>/dev/null || true
      fi
    fi
    rmdir "$STATE_DIR/.claim.lock" 2>/dev/null || true
    CLAIM_LOCK=""
  fi
  # mkdir failed → lock held by a peer (or stale). Skip claim; safe no-op.
fi

# ---------------------------------------------------------------------------
# 4. THE NO-OP PATH. No state file for this session → exit 0, no output.
#    This is the overwhelmingly common case for normal Claude Code usage.
#    Fix 4: a SYMLINKED state file is rejected — `[ -f ]` follows symlinks, so an
#    attacker-planted link could read an arbitrary file into the agent's context.
# ---------------------------------------------------------------------------
{ [ -f "$STATE" ] && [ ! -L "$STATE" ]; } || exit 0

# (C) Keep-alive touch: refresh STATE's mtime so the SessionStart GC treats
# this session as live. Silently no-ops on read-only FS or permission error.
touch "$STATE" 2>/dev/null || true

# Fix 3: size-cap the state file before reading it. A legit flowy-state-v1 file
# is well under 1KB; a pathological/corrupt giant file must not stall every
# prompt. Over 64KB → no-op.
STATE_BYTES="$(wc -c < "$STATE" 2>/dev/null || echo 0)"
# 2>/dev/null: suppress `[: integer expression expected` on shells where a
# non-numeric STATE_BYTES would make `[` fatal; the || exit 0 is the safe
# fallback either way.
[ "$STATE_BYTES" -le 65536 ] 2>/dev/null || exit 0

# Read the state file once.
STATE_CONTENT="$(cat "$STATE" 2>/dev/null || true)"
[ -n "$STATE_CONTENT" ] || exit 0

# ---------------------------------------------------------------------------
# 5. Deactivated / empty state → no-op. Requires both an "activeFlows" key and
#    at least one "name": entry.
# ---------------------------------------------------------------------------
printf '%s' "$STATE_CONTENT" | grep -q '"activeFlows"' || exit 0
printf '%s' "$STATE_CONTENT" | grep -q '"name"[[:space:]]*:' || exit 0

# ---------------------------------------------------------------------------
# 6. Parse active flows. Extract names and flowRefs in document order. The
#    activator writes one object per array element with name before flowRef,
#    so positional pairing holds. We tolerate a missing flowRef (auto-repair
#    from name still works).
# ---------------------------------------------------------------------------
NAMES="$(
  printf '%s' "$STATE_CONTENT" \
    | grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | sed 's/.*:[[:space:]]*"//; s/"$//' \
    | tr -d '\r'
)"
REFS="$(
  printf '%s' "$STATE_CONTENT" \
    | grep -o '"flowRef"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | sed 's/.*:[[:space:]]*"//; s/"$//' \
    | tr -d '\r'
)"
# RR1: optional per-entry "location" — "plugin" (default/absent) resolves under
# $PLUGIN_ROOT; "project" resolves under $PROJECT_DIR/.flowy/flows/<name>/FLOW.md.
# Parsed line-oriented and paired POSITIONALLY with NAMES, exactly like REFS. The
# activator writes one "location" per array element (it always emits the field),
# so the Nth location pairs with the Nth name. If the Nth location is absent/empty
# we default to plugin resolution — the SAFE direction (never silently project).
LOCATIONS="$(
  printf '%s' "$STATE_CONTENT" \
    | grep -o '"location"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | sed 's/.*:[[:space:]]*"//; s/"$//' \
    | tr -d '\r'
)"

[ -n "$NAMES" ] || exit 0

# Resolve each flow. Build accumulators:
#   LIVE_NAMES  — flows whose FLOW.md resolved (banner)
#   LIVE_REFS   — their resolved FLOW.md paths (banner; makes "re-read after
#                 compaction" actionable instead of a bare instruction)
#   CORRUPT     — flows active in state but unresolvable (warning)
LIVE_NAMES=""
LIVE_REFS=""
CORRUPT_NAMES=""

# Iterate names positionally; pull the Nth flowRef to match.
i=0
# Use a here-doc fed line loop; IFS preserved so names with no spaces are fine.
OLD_IFS="$IFS"
IFS='
'
# Fix (security audit #6): disable pathname expansion. IFS=newline stops
# word-splitting, but `for NAME in $NAMES` still GLOB-expands — a crafted name
# like "*" or "a[b]" would expand against the cwd and leak filenames into the
# loop (and the agent banner). set -f (noglob) closes it; restored after.
set -f
for NAME in $NAMES; do
  i=$((i + 1))
  # Nth flowRef (may be empty if fewer refs than names).
  REF="$(printf '%s\n' "$REFS" | sed -n "${i}p")"
  # Nth location (may be empty/absent → defaults to plugin resolution).
  LOC="$(printf '%s\n' "$LOCATIONS" | sed -n "${i}p")"

  RESOLVED=""
  # Reject a flowRef that tries to escape the plugin root.
  case "$REF" in
    *..* ) REF="" ;;  # drop traversal; fall through to auto-repair
  esac
  # Fix 5: charset allowlist. Before using REF in a path test, drop anything
  # containing a char outside [A-Za-z0-9_./-] — spaces, backslashes, shell
  # metachars, `$(...)` etc. Also reject a bare single dot. A dropped ref falls
  # through to name-based auto-repair, exactly like a stale ref.
  case "$REF" in
    *[!A-Za-z0-9_./-]* ) REF="" ;;  # disallowed char → drop
    '.' ) REF="" ;;                 # bare single-dot → drop
    *\\* ) REF="" ;;                # unreachable — backslash already caught by the charset guard above; kept for explicit intent.
  esac

  if [ "$LOC" = "project" ]; then
    # RR1: project-local flow. Resolve ONLY $PROJECT_DIR/.flowy/flows/<name>/FLOW.md.
    # No flowRef-based plugin resolution and NO plugin auto-repair fallback — a
    # location=project entry is explicit; falling back to the plugin path would
    # let a same-named bundled flow silently rescue a missing project flow. NAME
    # is semi-trusted; reuse the same charset/`..` guard as plugin auto-repair.
    case "$NAME" in
      *[!A-Za-z0-9_.-]* | *..* ) : ;;  # unsafe name → no resolution
      '' ) : ;;
      * )
        PCANON="$PROJECT_FLOWS_DIR/$NAME/FLOW.md"
        # RR3: reject a SYMLINKED resolved FLOW.md — `[ -f ]` follows symlinks, so
        # an attacker-planted link could read an arbitrary file into context.
        if [ -f "$PCANON" ] && [ ! -L "$PCANON" ]; then
          RESOLVED="$PCANON"
        fi
        ;;
    esac
  elif [ -n "$REF" ] && [ -f "$PLUGIN_ROOT/$REF" ] && [ ! -L "$PLUGIN_ROOT/$REF" ]; then
    # Plugin resolution via stored flowRef. RR3: reject a symlinked FLOW.md.
    RESOLVED="$PLUGIN_ROOT/$REF"
  else
    # Auto-repair: canonical layout flows/<name>/FLOW.md under the plugin root.
    # NAME is from the state file (semi-trusted); guard against traversal.
    case "$NAME" in
      *[!A-Za-z0-9_.-]* | *..* ) : ;;  # unsafe name → skip auto-repair
      '' ) : ;;
      * )
        CANON="$PLUGIN_ROOT/flows/$NAME/FLOW.md"
        # RR3: reject a symlinked resolved FLOW.md on the plugin path too.
        if [ -f "$CANON" ] && [ ! -L "$CANON" ]; then
          RESOLVED="$CANON"
        fi
        ;;
    esac
  fi

  # SANITIZE FOR OUTPUT. The banner/warning is injected verbatim into the
  # agent's CONTEXT, so a hand-edited/garbage state-file name could otherwise
  # smuggle misleading text (e.g. a fake "Routing:" directive) into context.
  # Strip NAME to the same charset we already trust for paths. Legit flow
  # names are slug-format ([a-z0-9-]) so this is lossless for every real flow;
  # it only neuters crafted names. A name that strips to empty becomes an
  # obviously-harmless literal placeholder, never injected text.
  SAFE_NAME="$(printf '%s' "$NAME" | sed 's/[^A-Za-z0-9_.-]//g')"
  [ -n "$SAFE_NAME" ] || SAFE_NAME="[invalid-name]"

  if [ -n "$RESOLVED" ]; then
    # LIVE_NAMES + LIVE_REFS are comma-joined in lockstep; both emitted in the
    # banner. RESOLVED is built from PLUGIN_ROOT + the already-allowlisted
    # REF/NAME (charset-guarded above), so it carries no injection vector.
    if [ -z "$LIVE_NAMES" ]; then
      LIVE_NAMES="$SAFE_NAME"
      LIVE_REFS="$RESOLVED"
    else
      LIVE_NAMES="$LIVE_NAMES, $SAFE_NAME"
      LIVE_REFS="$LIVE_REFS, $RESOLVED"
    fi
  else
    # CORRUPT_NAMES is NEWLINE-separated (Fix 6): one warning line per name, and
    # the read loop below splits ONLY on newline. The old IFS=', ' split also
    # broke on every space AND comma, which would mangle a name containing a
    # dot/space; newline iteration mirrors the clean NAMES loop above.
    if [ -z "$CORRUPT_NAMES" ]; then
      CORRUPT_NAMES="$SAFE_NAME"
    else
      CORRUPT_NAMES="$CORRUPT_NAMES
$SAFE_NAME"
    fi
  fi
done
set +f
IFS="$OLD_IFS"

# ---------------------------------------------------------------------------
# 7. Output. Live flows → loud banner. Corrupt flows → loud warning. Both can
#    appear. No active resolvable/corrupt flows → no output.
# ---------------------------------------------------------------------------
if [ -n "$LIVE_NAMES" ]; then
  printf '%s\n' "⚑ Flowy routing ACTIVE: $LIVE_NAMES. Before acting: evaluate the FLOW.md routing tree, state your Routing: decision, then INVOKE the matching skill (read its SKILL.md and follow it; do not inline from memory)."
  printf '%s\n' "Active Flows: $LIVE_NAMES"
  printf '%s\n' "FLOW.md (re-read after any context compaction): $LIVE_REFS"
fi

if [ -n "$CORRUPT_NAMES" ]; then
  # One warning line per corrupt flow keeps the message actionable. Iterate
  # newline-separated names (Fix 6): IFS= read -r splits ONLY on newline, so a
  # name containing a dot (e.g. "flow.v2") stays intact on a single line.
  printf '%s\n' "$CORRUPT_NAMES" | while IFS= read -r CN; do
    [ -n "$CN" ] || continue
    printf '%s\n' "⚠ Flowy: routing state for $CN is unreadable (FLOW.md not found). Re-activate with flowy:$CN, or run /flowy deactivate."
  done
fi

# Trap guarantees exit 0; be explicit anyway.
exit 0
