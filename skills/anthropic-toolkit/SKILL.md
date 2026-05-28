---
name: anthropic-toolkit
description: 13 official Anthropic skills bundled with a FLOW.md router — frontend design, webapp testing, Claude API, MCP builder, brand guidelines, and more.
---

# Activate anthropic-toolkit

Activate the anthropic-toolkit Flow for this session. After activation, FLOW.md routing becomes mandatory before every action.

## What this does

This skill delegates to the `/flowy` activator skill with the bundled Flow at `flows/anthropic-toolkit/`.

The /flowy activator will:
1. Read the FLOW.md at `flows/anthropic-toolkit/FLOW.md` (relative to this plugin's base directory)
2. Index the bundled skills in `flows/anthropic-toolkit/skills/`
3. Write `.flowy-state.json` to the project root
4. Enforce FLOW.md routing for the rest of the session

## Invocation

Invoke the `/flowy` skill with argument `anthropic-toolkit` AND with the additional context that the Flow lives at this plugin's `flows/anthropic-toolkit/` directory (the activator's LOCATE step will search the plugin base dir first).

If the /flowy skill is not available (user has not installed the global activator), print the manual fallback instructions:

1. Read this plugin's `flows/anthropic-toolkit/FLOW.md` directly
2. Internalize the routing decision tree
3. Before every turn, state your routing decision per the FLOW.md table
