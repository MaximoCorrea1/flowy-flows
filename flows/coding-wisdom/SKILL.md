---
name: coding-wisdom
description: 8 classic programming books distilled into agent-readable rules — Clean Code, Refactoring, DDD, DDIA, Pragmatic Programmer, Clean Architecture, Release It!, Legacy Code.
version: 0.1.0
license: MIT
---

# Coding Wisdom

Eight classic programming books, distilled into rules your AI agent
actually follows while coding.

## Attribution

The rule files in `books/` are **not my creation**. They are the work
of **Maciej Ciemborowicz** and contributors, from the
[agent-rules-books](https://github.com/mattpocock/agent-rules-books)
repository, licensed under the **MIT License** (see LICENSE).

The original rulesets were written as AGENTS.md files. Flowy bundles
them as a Flow with a FLOW.md router that loads the right ruleset
based on what the agent is doing.

## The 8 books

| Book | When the agent should follow it |
|------|-------------------------------|
| **Clean Code** (Robert C. Martin) | Writing new code — naming, functions, formatting |
| **Refactoring** (Martin Fowler) | Changing existing code without breaking it |
| **The Pragmatic Programmer** (Hunt & Thomas) | General engineering discipline + decision-making |
| **Clean Architecture** (Robert C. Martin) | Structuring modules, boundaries, dependencies |
| **Designing Data-Intensive Applications** (Kleppmann) | Data models, storage, distributed systems |
| **Domain-Driven Design** (Eric Evans) | Modeling complex business domains |
| **Working Effectively with Legacy Code** (Feathers) | Safely changing code without tests |
| **Release It!** (Nygard) | Production readiness, stability patterns, deployment |

## How to use

1. Copy this Flow folder into your project
2. Add the CLAUDE.md integration block from FLOW.md
3. Code normally — the agent loads the right ruleset based on context
