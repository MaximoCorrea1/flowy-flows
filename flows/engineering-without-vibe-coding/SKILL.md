---
name: engineering-without-vibe-coding
description: 7-phase pipeline from idea to shipped feature — ideate, spec, plan, execute, review, ship, compound.
version: 0.1.0
license: CC-BY-SA-4.0
---

<!-- License: CC-BY-SA-4.0. Copyright (c) 2026 Maximo Correa. -->

# Engineering With AI Without Vibe Coding

A discipline Flow for building real software with AI agents. Seven phases
take you from "I have an idea" to "it's shipped and documented" — with
gates between each phase that prevent the agent from skipping steps,
shipping untested code, or solving the wrong problem.

## Who this is for

Builders who use AI agents (Claude Code, Cursor, Claude Desktop, Codex)
and have been burned by vibe-coding: code that looks right at a glance
but breaks on edge cases the human never asked about. You want the agent's
speed without losing engineering discipline.

## How to use

1. Add this Flow to your project (copy the folder or reference it).
2. Point your agent at `FLOW.md` in this directory.
3. Describe what you want to build.
4. The agent follows the 7-phase pipeline. You approve at each gate.

No plugins required. No dependencies. Works with any language or framework.

## What's inside

- **FLOW.md** — the routing document. Tells the agent what to do at each
  phase, what output to produce, and what must be true before moving on.
- **examples/** — a redacted transcript showing the Flow in action on a
  real task.

## The 7 phases

1. **Ideate** — forcing questions before any code
2. **Spec** — lock the language, scope, and success criteria
3. **Plan** — break into implementation units with test scenarios
4. **Execute** — TDD: red → green → refactor → commit
5. **Review** — multi-lens code review (correctness, security, testing, style)
6. **Ship** — PR, merge, deploy, verify
7. **Compound** — retro + handoff + CONTEXT.md update

Each phase has a token-efficiency mode (FULL for thinking, MED for
structured output, CAVE for execution) that cuts token usage ~30-50%
without sacrificing quality where it matters.
