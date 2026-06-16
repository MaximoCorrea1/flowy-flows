#!/usr/bin/env sh
# =============================================================================
# flowy-paths.sh — SINGLE SOURCE OF TRUTH for the out-of-repo Flowy state dir.
# Sourced (never executed); defines flowy_canonical_key + flowy_state_dir +
# flowy_state_root.
#   * the hook + GC `. "$(dirname "$0")/flowy-paths.sh"` then call the functions.
#   * tests source the helper path explicitly (the helper is $1):
#       sh -c '. "$1"; flowy_state_dir "$2" "$3"' _ <helper-path> <projdir> <pluginroot>
#   * the activator passes the plugin root and builds the helper path from it:
#       sh -c '. "$1/hooks/flowy-paths.sh"; flowy_state_dir "${CLAUDE_PROJECT_DIR:-$2}" "$1"' _ <plugin-root> <projdir>
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
  # 1b. Detect a UNC root (\\server\share -> //server/share) BEFORE collapsing
  #     slashes, so a single-letter UNC server (//s/share) is NOT later mistaken
  #     for an MSYS drive mount (/s/share) and collapsed onto drive S:\share's key.
  _unc=0
  case "$_p" in //*) _unc=1 ;; esac
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
      # Single-letter root: an MSYS drive ONLY when actually under MSYS AND not a
      # collapsed UNC path (//s/... is a network share, not drive S).
      if [ "$_msys" = "1" ] && [ "$_unc" = "0" ]; then
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

# --- State ROOT (parent of every per-project dir) ----------------------------
# $1 = CLAUDE_PLUGIN_ROOT (carrying /plugins/) OR a claude-home ending /.claude.
# Echoes <claude-home>/flowy-state on success; nothing(+1) on no-op. The GC
# uses this to sweep ALL project dirs (it needs no project key).
flowy_state_root() {
  _src="$1"
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

  # Canonicalize a Windows drive prefix to the MSYS /<letter>/ form so the root
  # STRING is byte-identical whether the caller passed C:\..., C:/..., or /c/...
  # (all resolve to the same dir under Git Bash, but the hook + activator must
  # agree on the string, not just the physical path).
  case "$_home" in
    [A-Za-z]:/*)
      _hd="$(printf '%s' "$_home" | cut -c1 | tr 'A-Z' 'a-z')"
      _home="/$_hd/${_home#?:/}"
      ;;
  esac

  printf '%s' "$_home/flowy-state"
}

# --- Full state dir ----------------------------------------------------------
# $1 = CLAUDE_PROJECT_DIR (any form).
# $2 = CLAUDE_PLUGIN_ROOT (carrying /plugins/) OR a claude-home ending /.claude.
# Echoes STATE_DIR on success; echoes nothing and returns 1 on any no-op.
flowy_state_dir() {
  _pd="$1"
  [ -n "$_pd" ] || return 1
  _root="$(flowy_state_root "$2")" || return 1
  [ -n "$_root" ] || return 1
  _key="$(flowy_canonical_key "$_pd")" || return 1
  [ -n "$_key" ] || return 1
  printf '%s' "$_root/$_key"
}
