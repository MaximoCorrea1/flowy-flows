---
name: coding-wisdom
description: 8 classic programming books distilled into agent-readable rules — Clean Code, Refactoring, DDD, DDIA, Pragmatic Programmer, Clean Architecture, Release It!, Legacy Code. Session-start cheat-sheet priming + on-demand full ruleset loading.
---

# Activate coding-wisdom

Activate the coding-wisdom Flow for this session. After activation, FLOW.md routing becomes mandatory before every action.

## What this does

This skill invokes the bundled `flowy:_activator` skill (sibling skill in this plugin) with the flow name `coding-wisdom`. The activator handles:

1. Reading the FLOW.md at `../../flows/coding-wisdom/FLOW.md` (relative to this skill's directory — two levels up to the plugin root, then into the `flows/` directory)
2. Indexing the bundled skills
3. Writing `.flowy/state-PENDING.json`, which the auto-installed plugin hook claims for this session
4. Enforcing FLOW.md routing for the rest of the session

## Invocation

Invoke the `flowy:_activator` skill with argument `coding-wisdom`.

The activator will resolve paths relative to this plugin's root automatically. The current skill's base directory is `skills/coding-wisdom/`; the plugin root is two levels up.

## If the bundled activator is somehow unavailable

The bundled `_activator` skill should always be present in this plugin (it ships in the same plugin you installed). If for some reason it cannot be invoked, the manual fallback is:

1. Read this plugin's `../../flows/coding-wisdom/FLOW.md` directly (path relative to this skill's directory)
2. Internalize the routing decision tree
3. Before every turn, state routing decisions per the FLOW.md table

The fallback path does NOT write `.flowy/state-PENDING.json`, so the auto-installed hook has nothing to claim and routing does NOT survive context compaction. Use only as last resort.
