---
name: anthropic-design-test-flow
description: Anthropic's 13 design-and-test skills. Design a frontend, verify it with Playwright, then capture the loop as a reusable skill.
---

# Activate anthropic-design-test-flow

Activate the anthropic-design-test-flow Flow for this session. After activation, FLOW.md routing becomes mandatory before every action.

## What this does

This skill invokes the bundled `flowy:_activator` skill (sibling skill in this plugin) with the flow name `anthropic-design-test-flow`. The activator handles:

1. Reading the FLOW.md at `../../flows/anthropic-design-test-flow/FLOW.md` (relative to this skill's directory — two levels up to the plugin root, then into the `flows/` directory)
2. Indexing the bundled skills
3. Writing `.flowy/state-PENDING.json`, which the auto-installed plugin hook claims for this session
4. Enforcing FLOW.md routing for the rest of the session

## Invocation

Look at the argument THIS skill was invoked with, and forward to `flowy:_activator`:
- **No argument** (or anything that isn't `deactivate`/`status`) → activate: invoke `flowy:_activator` with argument `anthropic-design-test-flow`.
- **`deactivate`** (optionally followed by a flow name) → invoke `flowy:_activator` with argument `deactivate anthropic-design-test-flow` (use the user's named flow if they gave one). Turns this Flow off for THIS session only.
- **`status`** → invoke `flowy:_activator` with argument `status`.

So `/flowy:anthropic-design-test-flow` activates, `/flowy:anthropic-design-test-flow deactivate` turns it off, and `/flowy:anthropic-design-test-flow status` reports what's active + whether the hook is live.

The activator resolves paths relative to this plugin's root automatically. The current skill's base directory is `skills/anthropic-design-test-flow/`; the plugin root is two levels up.

## If the bundled activator is somehow unavailable

The bundled `_activator` skill should always be present in this plugin (it ships in the same plugin you installed). If for some reason it cannot be invoked, the manual fallback is:

1. Read this plugin's `../../flows/anthropic-design-test-flow/FLOW.md` directly (path relative to this skill's directory)
2. Internalize the routing decision tree
3. Before every turn, state routing decisions per the FLOW.md table

The fallback path does NOT write `.flowy/state-PENDING.json`, so the auto-installed hook has nothing to claim and routing does NOT survive context compaction. Use only as last resort.
