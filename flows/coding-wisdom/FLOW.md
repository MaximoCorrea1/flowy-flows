# FLOW.md: Coding Wisdom

> An overlay Flow: 8 classic programming books as always-on rules plus on-demand deep loads. Composes alongside any other Flow. Skills define WHAT to do; this defines HOW to write the code.
> Rules by Maciej Ciemborowicz (https://github.com/mattpocock/agent-rules-books, MIT). Routing by Flowy.

<!-- Overlay flow. The engine supplies the universal contract; this file carries a
     session-prime rules block + on-demand book-load routing. No phases. -->

## Session-prime (active all session)

These rules are binding for all code this session. The engine re-reads this file after compaction, so they persist. Load the full book (Routing, below) at the moment its trigger fires.

**Clean Code (Martin):** names explain purpose without comments; one word per concept. Functions do ONE thing, one level of abstraction, no boolean-flag params. No hidden side effects; commands and queries stay separate. Boy Scout Rule: leave every touched file cleaner.

**Refactoring (Fowler):** never start with a big rewrite. Safety net first, then preparatory refactor, then the functional change, then cleanup. Behavior-preserving steps only; keep structural edits and behavior changes in separate commits.

**Pragmatic Programmer (Hunt and Thomas):** DRY, one authoritative representation per fact. Design for replaceability; avoid irreversible decisions. Fix broken windows now. Crash early, fail loudly.

**Clean Architecture (Martin):** dependencies point inward; domain logic depends on nothing (not framework, DB, or UI). Stable things never depend on unstable things.

**DDIA (Kleppmann):** encode data assumptions explicitly, never let schema drift silently. Prefer idempotent writes; design for retries and partial failure. Separate reads that tolerate staleness from writes that need consistency.

**Domain-Driven Design (Evans):** use the Ubiquitous Language (code names match the domain experts). One model per bounded context, explicit translation at boundaries. Aggregates enforce invariants; reference other aggregates by identity only.

**Legacy Code (Feathers):** write a characterization test before touching untested code. Find the seam before changing behavior. Never change untested code without a failing test first.

**Release It! (Nygard):** timeouts on every external call; circuit breakers and bulkheads for isolation. Test failure modes, not just happy paths. Design for graceful degradation, no cascading failure.

## Routing (load the full book on demand)

Read the FULL file at the trigger moment, adjacent to the task, for maximum attention weight. Not at session start, not "when convenient".

```
WHAT YOU ARE ABOUT TO DO
  ├─ writing new functions / classes / modules?       → READ books/clean-code.md
  ├─ refactoring existing code?                        → READ books/refactoring.md
  ├─ an architecture decision (boundaries, dependency
  │   direction, a pattern used in >1 place)?          → READ books/clean-architecture.md
  ├─ designing data models / storage / distributed?   → READ books/designing-data-intensive-applications.md
  ├─ modeling a complex business domain?              → READ books/domain-driven-design.md
  ├─ touching code with no test coverage?             → READ books/working-effectively-with-legacy-code.md (characterization test FIRST)
  ├─ preparing for production / adding resilience?     → READ books/release-it.md
  └─ any general engineering trade-off?               → READ books/the-pragmatic-programmer.md
```

## Compose with

This overlay layers under any skill Flow. Example: inside superpowers-flow's test-driven-development, also READ books/clean-code.md the moment you write the first production function, so naming, parameter count, and abstraction obey Clean Code, not just TDD mechanics. The skill governs WHAT; Coding Wisdom governs HOW.

## You are rationalizing if you think…

- "I'll keep the rules in mind, no need to read the book." → Read the full file at the trigger. Primed rules fade by mid-session; the deep load is when it counts.
- "This code is fine as-is." → Boy Scout Rule. Leave it cleaner than you found it.
- "I'll add a test after I change it." → Untested code gets a characterization test FIRST (Legacy Code).
- "The rules are still in context after compaction." → After compaction, re-read this file; reload the session-prime rules and the on-demand triggers.

## Attribution

Rules in `books/` by Maciej Ciemborowicz, MIT (https://github.com/mattpocock/agent-rules-books). FLOW.md routing by Flowy, CC-BY-SA-4.0.
