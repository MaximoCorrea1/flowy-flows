---
name: solo-launch-playbook
description: 7-module marketing pipeline for solo founders — CRO audit, SEO research, content scoring, X threads, social content, outbound, growth experiments. From landing page to launch day to post-launch measurement.
---

# Activate solo-launch-playbook

Activate the solo-launch-playbook Flow for this session. After activation, FLOW.md routing becomes mandatory before every action.

## What this does

This skill delegates to the `/flowy` activator skill with the bundled Flow at `flows/solo-launch-playbook/`.

The /flowy activator will:
1. Read the FLOW.md at `flows/solo-launch-playbook/FLOW.md` (relative to this plugin's base directory)
2. Index the bundled skills in `flows/solo-launch-playbook/skills/`
3. Write `.flowy-state.json` to the project root
4. Enforce FLOW.md routing for the rest of the session

## Invocation

Invoke the `/flowy` skill with argument `solo-launch-playbook` AND with the additional context that the Flow lives at this plugin's `flows/solo-launch-playbook/` directory (the activator's LOCATE step will search the plugin base dir first).

If the /flowy skill is not available (user has not installed the global activator), print the manual fallback instructions:

1. Read this plugin's `flows/solo-launch-playbook/FLOW.md` directly
2. Internalize the routing decision tree
3. Before every turn, state your routing decision per the FLOW.md table
