#!/usr/bin/env sh
# =============================================================================
# flowy-paths.sh — SINGLE SOURCE OF TRUTH for the out-of-repo Flowy state dir.
# Sourced (never executed); defines flowy_canonical_key + flowy_state_dir.
#   * the hook + GC `. "$(dirname "$0")/flowy-paths.sh"` then call flowy_state_dir.
#   * the activator + tests invoke via:
#       sh -c '. "$1"; flowy_state_dir "$2" "$3"' _ <projdir> <pluginroot-or-home>
#
# WHY IT EXISTS (Bug E): three sites (hook, gc, activator) each derived the
# state key inline from CLAUDE_PROJECT_DIR with NO path normalization, so the
# same project under a Windows form (E:\ -> key E__...) and a Git-Bash/MSYS form
# (/e/ -> key _e_...) produced TWO keys -> the hook read a dir the activator
# never wrote -> the routing banner silently never fired. Centralizing here
# makes every caller compute a BYTE-IDENTICAL key.
#
# CANONICAL FORM = MINIMAL CHURN. We normalize toward the key the hook ALREADY
# produces in production (Windows backslash form, e.g. E__Projects_VS_x) so an
# upgrade does NOT orphan existing claimed state. Forward-slash POSIX paths
# (/home, /Users) are left byte-identical to today's `tr -c` output (no Linux/
# macOS churn). The MSYS single-letter-drive inference (/e/ -> E:\) is GATED on
# actually running under MSYS/MinGW/Cygwin, so a genuine POSIX dir like
# /e/realdir on Linux is NOT misread as drive E (no cross-OS key collision).
#
# OUTPUT CONTRACT: flowy_state_dir echoes the absolute STATE_DIR on success, or
# NOTHING and returns 1 on any no-op (empty input, home not ending /.claude,
# empty key). Callers treat empty output as a fail-loud no-op (never a wrong key).
#
# Git Bash on Windows; the repo path contains a space -> every expansion quoted.
# =============================================================================

# --- Canonical project key ---------------------------------------------------
# $1 = CLAUDE_PROJECT_DIR (any form). Echoes the canonical key (the string
# `tr -c 'A-Za-z0-9' '_'` yields from the Windows backslash form), or empty(+1).
flowy_canonical_key() {
  _p="$1"
  [ -n "$_p" ] || return 1

  # 1. backslashes -> slashes (so E:\a\b and E:/a/b normalize together).
  _p="$(printf '%s' "$_p" | tr '\\' '/')"
  # 2. collapse repeated slashes, then strip a single trailing slash.
  _p="$(printf '%s' "$_p" | sed 's#//*#/#g')"
  case "$_p" in
    */) _p="${_p%/}" ;;
  esac
  [ -n "$_p" ] || return 1

  # 3. MSYS/MinGW/Cygwin? Only there is a leading /<letter>/ a drive mount.
  _msys=0
  case "$(uname -s 2>/dev/null)" in
    MINGW* | MSYS* | CYGWIN*) _msys=1 ;;
  esac

  # 4. canonicalize drive forms to the Windows backslash form  X:\rest
  case "$_p" in
    [A-Za-z]:/*)
      # Windows / mixed drive form:  X:/rest
      _d="$(printf '%s' "$_p" | cut -c1 | tr 'a-z' 'A-Z')"
      _rest="${_p#?:/}"
      _p="$_d:\\$(printf '%s' "$_rest" | tr '/' '\\')"
      ;;
    /[A-Za-z]/*)
      # Single-letter root: an MSYS drive ONLY when actually under MSYS.
      if [ "$_msys" = "1" ]; then
        _d="$(printf '%s' "$_p" | cut -c2 | tr 'a-z' 'A-Z')"
        _rest="${_p#/?/}"
        _p="$_d:\\$(printf '%s' "$_rest" | tr '/' '\\')"
      fi
      # else: genuine POSIX path -> leave byte-identical.
      ;;
    *)
      : # POSIX (/home/...) or relative -> leave byte-identical.
      ;;
  esac

  # 5. the key: every non-alnum -> '_' (the established transform).
  printf '%s' "$_p" | tr -c 'A-Za-z0-9' '_'
}

# --- Full state dir ----------------------------------------------------------
# $1 = CLAUDE_PROJECT_DIR (any form).
# $2 = CLAUDE_PLUGIN_ROOT (carrying /plugins/) OR a claude-home ending /.claude.
# Echoes STATE_DIR on success; echoes nothing and returns 1 on any no-op.
flowy_state_dir() {
  _pd="$1"
  _src="$2"
  [ -n "$_pd" ] || return 1
  [ -n "$_src" ] || return 1

  # Normalize separators so a Windows-form plugin root (C:\...\plugins\...) is
  # split the same as the POSIX form (/c/.../plugins/...).
  _src="$(printf '%s' "$_src" | tr '\\' '/')"

  # claude-home = everything before the LAST /plugins/ segment. With no /plugins/
  # segment, accept the input directly only when it is already a /.claude home
  # (lets a caller pass either the plugin root or the home).
  _home="${_src%/plugins/*}"
  if [ "$_home" = "$_src" ]; then
    case "$_src" in
      */.claude) _home="$_src" ;;
      *) return 1 ;;
    esac
  fi
  # HARD guard: must resolve to a /.claude home (unexpected layout -> no-op).
  case "$_home" in
    */.claude) : ;;
    *) return 1 ;;
  esac

  _key="$(flowy_canonical_key "$_pd")" || return 1
  [ -n "$_key" ] || return 1

  printf '%s' "$_home/flowy-state/$_key"
}
