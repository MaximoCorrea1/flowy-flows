---
name: superpowers-flow
description: All 14 superpowers skills bundled with a FLOW.md router that auto-invokes the right skill at the right moment. Curated by Flowy.
version: 0.2.0
license: MIT
upstream: https://github.com/obra/superpowers
attribution: Skills by Jesse Vincent
---

# Superpowers Flow

All 14 [superpowers](https://github.com/obra/superpowers) skills by
**Jesse Vincent**, bundled with a FLOW.md routing document that makes
them auto-invoke based on context.

## Attribution

The skills in `skills/` are **not my creation**. They are the work of
[Jesse Vincent (obra)](https://github.com/obra) and contributors, from
the [superpowers](https://github.com/obra/superpowers) project, licensed
under the **MIT License** (see LICENSE in this directory).

What I added: the `FLOW.md` routing document. The skills are the atoms.
The FLOW.md is the glue that tells the agent WHEN to invoke each skill.

## Why this Flow exists

Superpowers is the most complete agent-discipline skill set available:
brainstorming, planning, TDD, debugging, code review, verification,
branch management, parallel execution, worktrees, and skill authoring.

The problem: **skills don't auto-invoke.** An agent with superpowers
on disk will happily skip brainstorming, write code without TDD, ship
without review, and claim "done" without verification. The skills exist
but the agent doesn't know when to fire them.

This FLOW.md solves that. It defines a routing table the agent checks
before every action. When a trigger matches, the agent reads and follows
the corresponding skill. No skipping. No rationalizing. The skill fires
or the workflow is violated.

## How to use

Run `/flowy:superpowers-flow` to activate. The Flowy hook then enforces FLOW.md routing for the rest of the session, with no manual setup. (`/flowy:superpowers-flow status` to verify; `/flowy:superpowers-flow deactivate` to turn off.)

## What's inside

```
superpowers-flow/
├── SKILL.md          # This file (overview + attribution)
├── FLOW.md           # Routing document: the value-add
├── LICENSE           # MIT (same as superpowers)
├── skills/           # All 14 superpowers skills (Jesse Vincent, MIT)
│   ├── brainstorming/
│   ├── dispatching-parallel-agents/
│   ├── executing-plans/
│   ├── finishing-a-development-branch/
│   ├── receiving-code-review/
│   ├── requesting-code-review/
│   ├── subagent-driven-development/
│   ├── systematic-debugging/
│   ├── test-driven-development/
│   ├── using-git-worktrees/
│   ├── using-superpowers/
│   ├── verification-before-completion/
│   ├── writing-plans/
│   └── writing-skills/
└── examples/
    └── example-session.md
```

## The 14 skills (by Jesse Vincent)

| Skill | When the FLOW.md invokes it |
|-------|---------------------------|
| brainstorming | New idea, unclear scope |
| writing-plans | Spec exists, need implementation tasks |
| executing-plans | Plan exists, working through tasks serially |
| subagent-driven-development | 3+ independent tasks, want parallelism |
| dispatching-parallel-agents | Ad-hoc parallel fan-out |
| test-driven-development | About to write any implementation code |
| systematic-debugging | Something is broken, cause unknown |
| verification-before-completion | About to claim anything is "done" |
| requesting-code-review | Code complete, need review |
| receiving-code-review | Got review feedback |
| finishing-a-development-branch | All tasks done, branch ready to land |
| using-git-worktrees | Need isolated parallel branches |
| writing-skills | Creating a custom skill |
| using-superpowers | Meta: how the skill system works |
