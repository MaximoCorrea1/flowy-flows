# FLOW.md — Coding Wisdom

> Eight classic programming books distilled into agent-readable rules.
> Architecture: cheat-sheet priming at session start + full ruleset
> loaded on demand at the moment of invocation.
>
> Rules by Maciej Ciemborowicz (MIT, https://github.com/mattpocock/agent-rules-books).
> FLOW.md routing by Flowy.

---

## Session-start anchor (ALWAYS include in CLAUDE.md)

Paste this block into your project's CLAUDE.md:

```markdown
## Coding Wisdom — active rules

At session start, internalize these rules. They are binding for all code in this session.

### Clean Code (Martin) — naming + functions
- Names must explain purpose without comments. Use one word per concept. Verbs for functions, nouns for classes.
- Functions do ONE thing. One level of abstraction per function. No boolean flag params — split instead.
- Eliminate side effects. Commands and queries are separate. Error handling is isolated, not inline.
- Boy Scout Rule: leave every touched file cleaner than you found it.

### Refactoring (Fowler) — changing existing code
- Never start with a large rewrite. Next safe structural improvement first.
- Sequence: safety net → preparatory refactoring → functional change → cleanup.
- Behavior-preserving steps only. Separate structural edits from behavior changes in commits.
- Never mix architecture migration + feature work + cleanup in one patch.

### Pragmatic Programmer (Hunt & Thomas) — engineering discipline
- DRY: every piece of knowledge has one authoritative representation.
- Design for replaceability. Avoid irreversible decisions.
- Fix broken windows immediately. Don't leave bad code because "it was already there."
- Crash early, fail loudly. Defensive programming over silent corruption.

### Clean Architecture (Martin) — module boundaries
- Dependencies point inward. Domain logic does not depend on frameworks, DBs, or UI.
- Entities > Use Cases > Interface Adapters > Frameworks. Never invert this.
- Stable things do not depend on unstable things.

### DDIA (Kleppmann) — data + distributed systems
- Encode data assumptions explicitly. Never let schema drift silently.
- Prefer idempotent writes. Design for retries and partial failures.
- Distinguish reads that can tolerate staleness from writes that require consistency.

### Domain-Driven Design (Evans) — business domains
- Use Ubiquitous Language: code names match domain expert vocabulary exactly.
- Bounded Context: one model per context, explicit translation at boundaries.
- Aggregates enforce invariants. Only reference other aggregates by identity.

### Legacy Code (Feathers) — untested code
- Write characterization tests before touching any untested code.
- Seams: find the point of isolation before changing behavior.
- Never change untested code without a failing test first.

### Release It! (Nygard) — production readiness
- Circuit breakers on every external call. Timeouts everywhere. Bulkheads for isolation.
- Test for failure modes, not just happy paths.
- Design for graceful degradation. One failing dependency must not cascade.
```

---

## On-demand full ruleset loading

The cheat-sheet above primes the session. When the specific trigger fires,
READ THE FULL RULESET to get complete rule depth for that task.

The agent MUST read the full file at the trigger moment — not earlier,
not "when convenient". The file read happens adjacent to the task so rules
receive maximum attention weight.

```
WHAT THE AGENT IS DOING RIGHT NOW
  │
  ├─ Writing new functions, classes, or modules?
  │   → READ: books/clean-code.md
  │   (at the moment of writing, before the first line of new code)
  │
  ├─ Refactoring existing code?
  │   → READ: books/refactoring.md
  │   (before the first structural change, not at session start)
  │
  ├─ Making an architecture decision (module split, dependency direction,
  │   provider choice, new pattern used in >1 place)?
  │   → READ: books/clean-architecture.md
  │   (before deciding, not after)
  │
  ├─ Designing data models, storage strategy, or working with distributed state?
  │   → READ: books/designing-data-intensive-applications.md
  │
  ├─ Modeling a complex business domain or introducing domain entities?
  │   → READ: books/domain-driven-design.md
  │
  ├─ Touching code that has no test coverage?
  │   → READ: books/working-effectively-with-legacy-code.md
  │   (characterization tests FIRST, then change — do not skip this)
  │
  ├─ Preparing for production, adding resilience, or reviewing a deploy?
  │   → READ: books/release-it.md
  │
  └─ Any general engineering decision about trade-offs, tool choice, or
     long-term cost?
      → READ: books/the-pragmatic-programmer.md
```

---

## What changed from v0.1 (why this architecture)

The v0.1 model instructed agents to "load rules at session start as background
context." This fails because:

1. Context injected 10+ turns ago falls into the "lost in the middle" attention
   zone. Rules loaded at token 0 have near-zero influence at turn 15.
2. Two books at session start = ~8,800 tokens. All eight triggered = ~14,600 tokens.
   That is 30-50% of effective context on one task.
3. "Read and keep active" has no evaluation hook — the agent has no mechanism
   to know when it forgot the rules.

The hybrid model fixes all three:
- The 200-token cheat-sheet stays in the high-attention prefix zone. Short enough
  to matter, concrete enough to prime style.
- Full book loads ON DEMAND, adjacent to the task — maximum attention weight at
  exactly the right moment.
- Total default token cost: ~1,600 tokens (8 × 200). On-demand adds ~3,500 tokens
  only when the trigger fires, not permanently.

---

## Combining with other Flows

This Flow works alongside skill-based Flows (like superpowers-flow).
Skills define WHAT to do (TDD, review, debug). Coding Wisdom defines HOW
to write the code while doing it.

Example: agent enters `test-driven-development` skill. It also reads
`books/clean-code.md` at the moment it writes the first production function —
so function naming, parameter count, and abstraction level are governed by
Clean Code rules, not just TDD mechanics.

---

## Attribution

Rule files from [agent-rules-books](https://github.com/mattpocock/agent-rules-books)
by Maciej Ciemborowicz, MIT License.
FLOW.md routing by [Flowy](https://flowy.dev).
