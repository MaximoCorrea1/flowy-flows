# FLOW.md — Coding Wisdom

> Eight classic programming books as agent-readable rules. The router
> loads the right ruleset based on what the agent is doing.
>
> Rules by Maciej Ciemborowicz (MIT, https://github.com/mattpocock/agent-rules-books).
> FLOW.md routing by Flowy.

## How this works

Each file in `books/` contains the distilled rules from one programming
book. When the routing table matches a trigger, the agent reads that
book's rules and applies them to the current work.

Rules are NOT invoked like skills (they don't have a step-by-step
process). They're LOADED as context — the agent reads the rules and
keeps them active while coding. Multiple rulesets can be active at once.

---

## CLAUDE.md Integration

Paste into your project's CLAUDE.md:

```markdown
## Coding rules (Coding Wisdom Flow)

Read at session start: [path-to-this-flow]/FLOW.md

When working on code, load the appropriate ruleset(s) from the table
below. Multiple rulesets can be active simultaneously. Read each file
and apply its rules to your work.

| When you are... | Load these rules |
|----------------|-----------------|
| Writing new functions, classes, or modules | books/clean-code.md |
| Refactoring or improving existing code | books/refactoring.md |
| Making any engineering decision | books/the-pragmatic-programmer.md |
| Designing module boundaries or dependencies | books/clean-architecture.md |
| Working with data models, databases, or distributed state | books/designing-data-intensive-applications.md |
| Modeling a complex business domain | books/domain-driven-design.md |
| Changing code that has no tests | books/working-effectively-with-legacy-code.md |
| Preparing for production, adding resilience, or deploying | books/release-it.md |
```

---

## Routing Logic

Unlike skill-based Flows (where the agent follows a skill's steps),
this Flow loads RULES as background context. The rules shape HOW the
agent codes, not WHAT it does.

### Default rules (always active)

These should be loaded at session start for any coding work:
- `books/clean-code.md` — naming, functions, formatting
- `books/the-pragmatic-programmer.md` — general discipline

### Situational rules (load when the trigger matches)

```
WHAT THE AGENT IS DOING
  │
  ├─ Refactoring existing code?
  │   → ALSO load books/refactoring.md
  │
  ├─ Designing module structure / boundaries?
  │   → ALSO load books/clean-architecture.md
  │
  ├─ Working with databases / data pipelines / distributed systems?
  │   → ALSO load books/designing-data-intensive-applications.md
  │
  ├─ Modeling a complex business domain?
  │   → ALSO load books/domain-driven-design.md
  │
  ├─ Changing code that has no test coverage?
  │   → ALSO load books/working-effectively-with-legacy-code.md
  │   (characterization tests first, then change)
  │
  └─ Preparing for deployment / adding resilience?
      → ALSO load books/release-it.md
```

### Combining with other Flows

This Flow works alongside skill-based Flows (like superpowers-flow).
The skills tell the agent WHAT to do (TDD, review, debug). The coding
wisdom rules tell it HOW to write the code while doing it.

Example: the agent is in the `test-driven-development` skill from
superpowers-flow, writing a new function. It also has `clean-code.md`
rules active — so the function it writes follows Clean Code naming,
formatting, and function-length guidelines.

---

## Attribution

Rule files from [agent-rules-books](https://github.com/mattpocock/agent-rules-books)
by Maciej Ciemborowicz, MIT License.
FLOW.md routing by [Flowy](https://flowy.dev).
