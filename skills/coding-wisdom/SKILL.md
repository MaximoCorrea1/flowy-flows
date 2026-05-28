---
name: coding-wisdom
description: 8 classic programming books distilled into agent-readable rules — Clean Code, Refactoring, DDD, DDIA, Pragmatic Programmer, Clean Architecture, Release It!, Legacy Code. Session-start cheat-sheet priming + on-demand full ruleset loading.
---

# Activate coding-wisdom

Activate the coding-wisdom Flow for this session. After activation, FLOW.md routing becomes mandatory before every action.

## What this does

This skill delegates to the `/flowy` activator skill with the bundled Flow at `flows/coding-wisdom/`.

The /flowy activator will:
1. Read the FLOW.md at `flows/coding-wisdom/FLOW.md` (relative to this plugin's base directory)
2. Index the bundled skills in `flows/coding-wisdom/skills/`
3. Write `.flowy-state.json` to the project root
4. Enforce FLOW.md routing for the rest of the session

## Invocation

Invoke the `/flowy` skill with argument `coding-wisdom` AND with the additional context that the Flow lives at this plugin's `flows/coding-wisdom/` directory (the activator's LOCATE step will search the plugin base dir first).

If the /flowy skill is not available (user has not installed the global activator), print the manual fallback instructions:

1. Read this plugin's `flows/coding-wisdom/FLOW.md` directly
2. Internalize the routing decision tree
3. Before every turn, state your routing decision per the FLOW.md table
