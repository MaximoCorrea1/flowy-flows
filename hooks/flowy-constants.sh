#!/usr/bin/env sh
# flowy-constants.sh — single source of Flowy timing constants. Sourced, never executed.
FLOWY_PENDING_TTL_SECONDS=120   # robust-hybrid only: max age of a claimable PENDING
FLOWY_STATE_GC_DAYS=14          # SessionStart GC: delete state-*.json older than this
