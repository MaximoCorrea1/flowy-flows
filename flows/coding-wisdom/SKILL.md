---
name: coding-wisdom
description: 8 classic programming books distilled into agent-readable rules — Clean Code, Refactoring, DDD, DDIA, Pragmatic Programmer, Clean Architecture, Release It!, Legacy Code. Session-start cheat-sheet priming + on-demand full ruleset loading.
version: 0.3.0
license: MIT
upstream: https://github.com/mattpocock/agent-rules-books
attribution: Rules by Maciej Ciemborowicz
---

# Coding Wisdom

Eight classic programming books, distilled into rules your AI agent
actually follows while coding.

## Architecture (v0.2)

This Flow uses a **hybrid delivery model** designed around how attention
mechanisms work:

1. **Session-start cheat-sheet** — 8 books × ~200 tokens of the most
   important rules, inlined into CLAUDE.md. Stays in the high-attention
   prefix zone for the entire session. Primes style decisions immediately.

2. **On-demand full ruleset** — when a specific trigger fires (writing a
   new function, refactoring, designing a data model), the agent reads the
   FULL book file at that moment — adjacent to the task, maximum attention
   weight, minimum token bloat.

**Why not "load all rules at session start":** rules loaded at token 0 fall
into the "lost in the middle" attention zone by turn 10–15. The v0.1 model
consumed 8,800–14,600 tokens for near-zero influence. This model uses 1,600
tokens default and adds full depth exactly when needed.

## The 8 books

| Book | Full file | On-demand trigger |
|------|-----------|-------------------|
| **Clean Code** (Martin) | `books/clean-code.md` | Writing new functions, classes, or modules |
| **Refactoring** (Fowler) | `books/refactoring.md` | Changing existing code structure |
| **The Pragmatic Programmer** (Hunt & Thomas) | `books/the-pragmatic-programmer.md` | Any significant engineering trade-off |
| **Clean Architecture** (Martin) | `books/clean-architecture.md` | Module boundaries, dependency direction |
| **Designing Data-Intensive Applications** (Kleppmann) | `books/designing-data-intensive-applications.md` | Data models, storage, distributed systems |
| **Domain-Driven Design** (Evans) | `books/domain-driven-design.md` | Modeling complex business domains |
| **Working Effectively with Legacy Code** (Feathers) | `books/working-effectively-with-legacy-code.md` | Touching untested code |
| **Release It!** (Nygard) | `books/release-it.md` | Production readiness, resilience, deployment |

## How to install

Run `/flowy:coding-wisdom` to activate. The Flowy hook enforces the FLOW.md (its session-prime rules + on-demand book loads) for the rest of the session, with no manual setup. (`/flowy:coding-wisdom status` to verify; `/flowy:coding-wisdom deactivate` to turn off.)

## Attribution

The rule files in `books/` are **not my creation**. They are the work of
**Maciej Ciemborowicz** and contributors, from the
[agent-rules-books](https://github.com/mattpocock/agent-rules-books)
repository, licensed under the **MIT License** (see LICENSE).

The original rulesets were written as AGENTS.md files. Flowy bundles them
as a Flow with a FLOW.md router that loads the right ruleset based on what
the agent is doing.
