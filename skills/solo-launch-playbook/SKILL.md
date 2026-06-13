---
name: solo-launch-playbook
description: 7-module marketing pipeline for solo founders — CRO audit, SEO research, content scoring, X threads, social content, outbound, growth experiments. From landing page to launch day to post-launch measurement.
---

# Activate solo-launch-playbook

Activate the solo-launch-playbook Flow for this session. After activation, FLOW.md routing becomes mandatory before every action.

## What this does

This skill invokes the bundled `flowy:_activator` skill (sibling skill in this plugin) with the flow name `solo-launch-playbook`. The activator handles:

1. Reading the FLOW.md at `../../flows/solo-launch-playbook/FLOW.md` (relative to this skill's directory — two levels up to the plugin root, then into the `flows/` directory)
2. Indexing the bundled skills
3. Writing `.flowy/state-PENDING.json`, which the auto-installed plugin hook claims for this session
4. Enforcing FLOW.md routing for the rest of the session

## Invocation

Look at the argument THIS skill was invoked with, and forward to `flowy:_activator`:
- **No argument** (or anything that isn't `deactivate`/`status`) → activate: invoke `flowy:_activator` with argument `solo-launch-playbook`.
- **`deactivate`** (optionally followed by a flow name) → invoke `flowy:_activator` with argument `deactivate solo-launch-playbook` (use the user's named flow if they gave one). Turns this Flow off for THIS session only.
- **`status`** → invoke `flowy:_activator` with argument `status`.

So `/flowy:solo-launch-playbook` activates, `/flowy:solo-launch-playbook deactivate` turns it off, and `/flowy:solo-launch-playbook status` reports what's active + whether the hook is live.

The activator resolves paths relative to this plugin's root automatically. The current skill's base directory is `skills/solo-launch-playbook/`; the plugin root is two levels up.

## If the bundled activator is somehow unavailable

The bundled `_activator` skill should always be present in this plugin (it ships in the same plugin you installed). If for some reason it cannot be invoked, the manual fallback is:

1. Read this plugin's `../../flows/solo-launch-playbook/FLOW.md` directly (path relative to this skill's directory)
2. Internalize the routing decision tree
3. Before every turn, state routing decisions per the FLOW.md table

The fallback path does NOT write `.flowy/state-PENDING.json`, so the auto-installed hook has nothing to claim and routing does NOT survive context compaction. Use only as last resort.
