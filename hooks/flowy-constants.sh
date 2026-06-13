#!/usr/bin/env sh
# flowy-constants.sh — single source of Flowy timing constants. Sourced, never executed.
FLOWY_PENDING_TTL_SECONDS=600   # max age of a claimable PENDING. Tuned for activation reliability:
                                # the window is activation -> the user's FIRST next prompt, so it must
                                # tolerate a user who activates then reads/thinks for several minutes.
                                # Leak cost of a longer TTL (another session prompting in the SAME
                                # project within the window) is rare for the solo-founder case.
FLOWY_STATE_GC_DAYS=14          # SessionStart GC: delete state-*.json older than this
