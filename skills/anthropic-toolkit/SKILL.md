---
name: anthropic-toolkit
description: 13 official Anthropic skills bundled with a FLOW.md router — frontend design, webapp testing, Claude API, MCP builder, brand guidelines, and more.
---

# Activate anthropic-toolkit

Activate the anthropic-toolkit Flow for this session. After activation, FLOW.md routing becomes mandatory before every action.

## What this does

This skill invokes the bundled `flowy:_activator` skill (sibling skill in this plugin) with the flow name `anthropic-toolkit`. The activator handles:

1. Reading the FLOW.md at `../../flows/anthropic-toolkit/FLOW.md` (relative to this skill's directory — two levels up to the plugin root, then into the `flows/` directory)
2. Indexing the bundled skills
3. Writing `.flowy-state.json` to the project root
4. Enforcing FLOW.md routing for the rest of the session

## Invocation

Invoke the `flowy:_activator` skill with argument `anthropic-toolkit`.

The activator will resolve paths relative to this plugin's root automatically. The current skill's base directory is `skills/anthropic-toolkit/`; the plugin root is two levels up.

## If the bundled activator is somehow unavailable

The bundled `_activator` skill should always be present in this plugin (it ships in the same plugin you installed). If for some reason it cannot be invoked, the manual fallback is:

1. Read this plugin's `../../flows/anthropic-toolkit/FLOW.md` directly (path relative to this skill's directory)
2. Internalize the routing decision tree
3. Before every turn, state routing decisions per the FLOW.md table

The fallback path does NOT write `.flowy-state.json` and does NOT survive context compaction. Use only as last resort.
