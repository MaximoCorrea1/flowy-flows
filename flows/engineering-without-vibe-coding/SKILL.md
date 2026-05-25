---
name: engineering-without-vibe-coding
description: Routing layer over superpowers skills — auto-invokes the right skill at the right moment so agents stop vibe-coding and start engineering.
version: 0.2.0
license: CC-BY-SA-4.0
requires: superpowers (https://github.com/obra/superpowers)
---

<!-- License: CC-BY-SA-4.0. Copyright (c) 2026 Maximo Correa. -->
<!-- Requires: superpowers plugin by Jesse Vincent (MIT). Install via: -->
<!-- npx skills@latest add obra/superpowers-marketplace              -->

# Engineering Without Vibe Coding

Superpowers gives you 14 skills. This Flow tells your agent WHEN to use
each one.

The problem: skills don't auto-invoke. An agent with superpowers installed
will happily skip brainstorming, write code without TDD, ship without
review, and claim "done" without verification. The skills exist on disk
but the agent doesn't know when to fire them.

This FLOW.md solves that. It defines an event → skill routing table that
the agent checks before every action. When a trigger matches, the agent
MUST invoke the corresponding skill via the Skill tool. No skipping. No
"I'll handle it inline." The skill fires or the workflow is violated.

## How to use

1. Install superpowers: `npx skills@latest add obra/superpowers-marketplace`
2. Copy this Flow folder into your project (or reference it from CLAUDE.md)
3. Add the CLAUDE.md integration block from FLOW.md to your project's CLAUDE.md
4. Start working. The agent auto-routes to the right skill at each step.

## What's inside

- **FLOW.md** — the routing document. Event triggers → skill invocations.
  Paste the integration block into your CLAUDE.md and the routing is live.
- **examples/** — transcript showing the routing in action.

## The 14 skills this Flow routes

| Skill | When it fires |
|-------|---------------|
| `brainstorming` | New idea, unclear scope |
| `writing-plans` | Spec exists, need tasks |
| `executing-plans` | Plan exists, working through it |
| `subagent-driven-development` | 3+ independent tasks, want parallelism |
| `dispatching-parallel-agents` | Need to fan-out workers |
| `test-driven-development` | About to write any implementation code |
| `systematic-debugging` | Something is broken, cause unknown |
| `verification-before-completion` | About to claim anything is "done" |
| `requesting-code-review` | Code complete, need review |
| `receiving-code-review` | Got review feedback, need to process it |
| `finishing-a-development-branch` | All tasks done, branch ready |
| `using-git-worktrees` | Need isolated parallel branches |
| `writing-skills` | Want to create a custom skill |
| `using-superpowers` | Meta: how the skill system works |
