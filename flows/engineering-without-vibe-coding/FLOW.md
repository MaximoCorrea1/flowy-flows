# FLOW.md — Engineering With AI Without Vibe Coding

## Goal

Help a builder use AI agents to ship real software without sliding into
vibe-coding — where the agent generates plausible-looking code that
breaks on edge cases the human never asked about.

## When to invoke

- Builder is starting a new feature or project
- Builder caught themselves accepting agent output without verifying
- Project has lost the through-line between intent and shipped code
- Builder wants to resume a prior session with discipline intact

## Skills used

None required. This Flow is standalone — no plugins, no dependencies.
It composes YOUR project's own tools: your test runner, your linter,
your deployment pipeline, your version control. The Flow provides the
routing; your stack provides the execution.

## Phases

Seven phases, in order. Each phase has:
- **Mode:** how verbose the agent should be (FULL / MED / CAVE)
- **Instructions:** what the agent does
- **Gate:** what must be true before the next phase unlocks

Phases can be invoked standalone. "I just need a review" → jump to
Phase 5. The gate doesn't require the prior phase to have run in THIS
session — just that the gate artifact exists (from a prior session, a
human-written doc, or the current conversation).

---

### Phase 1: Ideate

**Mode:** FULL (thinking IS the work — do not compress)

**Instructions:**

Before touching any code, ask these forcing questions:

1. **Demand reality.** What's the strongest evidence someone wants this —
   not "is interested," but would be upset if it disappeared?
2. **Status quo.** What do users do today to solve this problem, even
   badly? What does the workaround cost them?
3. **Narrowest wedge.** What's the smallest version someone would use
   this week — not after you build the platform?
4. **Existing code.** What in the current codebase already partially
   solves this? Can we capture existing outputs rather than building
   from scratch?
5. **Do-nothing test.** If we do nothing, what happens? Real pain or
   hypothetical?

Do NOT write code, scaffold, or open implementation files in this phase.

**Output:** A written problem statement. Can be 3 paragraphs in chat, a
section in a doc, or an entry in CONTEXT.md. Format doesn't matter;
existence does.

**Gate:** The problem statement exists as written text that both the
human and the agent can point to. If the user says "skip — I know what
I want," ask them to state the problem in one sentence. That sentence
IS the gate artifact.

---

### Phase 2: Spec

**Mode:** FULL (lock the language before the architecture)

**Instructions:**

You are the skeptical cofounder in this phase. Your job is to make sure
the builder knows what they're building before HOW they build it.

1. **Domain terms.** Read CONTEXT.md (create it if missing). For every
   new domain term that emerges in conversation, add it immediately.
   A term is anything the builder uses that has a project-specific
   meaning ("listing," "flow," "invocation," "creator"). If you're
   not sure whether a word is a domain term, it is.

2. **Scope boundaries.** State what is IN this task and what is NOT.
   Write it down. "In scope: X, Y, Z. Not in scope: A, B, C." Vague
   scope = vibe-coding. Explicit scope = engineering.

3. **Success criteria.** How will we know this worked? Specific and
   testable: "page loads in <2s," "5+ users sign up," "test suite
   passes with 0 failures." Not "it works" or "it feels right."

4. **Decisions.** For every non-obvious choice (this library vs that
   one, this pattern vs that one, this table schema vs that one),
   write a short ADR: what we chose, why, what we rejected. One
   paragraph per decision. Save to `docs/adr/` or inline in chat.

Push back on vague scope. Ask "what does [term] mean in THIS project?"
for any ambiguous word. Do not accept hand-waving.

**Output:** Scope boundaries + success criteria + CONTEXT.md updated.
For small tasks (<200 LOC): 3 lines in chat is enough. For larger work:
a spec doc.

**Gate:** User approves the spec. Minimum: scope boundaries stated,
success criteria stated, CONTEXT.md current.

---

### Phase 3: Plan

**Mode:** MED (structured output — tables, bullets, checkboxes)

**Instructions:**

Break the work into implementation units. Each unit is one meaningful
change that could land as an atomic commit.

For each unit, define:

- **Goal:** one sentence — what this unit accomplishes
- **Files:** exact paths to create, modify, or test
- **Approach:** the strategy (not the code). Key design decisions,
  integration notes, data flow
- **Test scenarios:** specific test cases. Each scenario names the
  input, the action, and the expected outcome. Include:
  - Happy path (always)
  - Edge cases (when meaningful boundaries exist)
  - Error paths (when failure modes exist)
  - Integration (when crossing layers — callbacks, middleware, etc.)
- **Verification:** how the implementer knows this unit is done

Order units by dependency. Note which units can run in parallel
(no shared files, no sequential dependency). Use checkbox syntax
(`- [ ]`) for progress tracking.

**Output:** A plan — in chat for small tasks, or saved as a markdown
file for larger work.

**Gate:** User approves the plan. "Is this the right breakdown? Right
order? Right scope per unit?" If the user says "just do it," present a
3-line summary and get a thumbs-up.

---

### Phase 4: Execute

**Mode:** CAVE (terse — execute, don't explain)

**Instructions:**

For each unit in the plan, in dependency order:

1. Mark the unit in-progress
2. Read the files referenced in the unit
3. **Write the failing test first (RED)**
4. Run the test — confirm it fails with the expected error
5. **Write the minimal code to make it pass (GREEN)**
6. Run the test — confirm it passes
7. **Refactor** if the code is ugly (clean up without changing behavior)
8. **Commit** with a meaningful message referencing the unit

TDD exceptions — skip test-first for:
- Pure configuration (env vars, package.json)
- Documentation changes
- Styling-only changes (CSS, Tailwind classes)

For these, apply verification-before-completion instead: open the
actual page, read the actual config back, confirm it does what it
should.

CAVE mode output:
```
Writing test for [unit].
Test fails: [expected error].
Implementing.
Test passes.
Committing: "feat(scope): [description]"
```

No preamble. No explanation of intent. No "I'll now proceed to..."
Just the work.

One commit per completed unit. Never batched at the end.

For parallel work: if the plan noted independent units, dispatch
subagent workers — one per unit. Each worker receives the unit's
goal, files, approach, test scenarios, and verification criteria.
Workers follow the same RED → GREEN → REFACTOR → COMMIT rhythm.

**Gate:** All plan checkboxes checked. All tests green. No uncommitted
changes.

---

### Phase 5: Review

**Mode:** MED (structured findings)

**Instructions:**

Review the diff (all commits since the plan was approved) through four
lenses. For each finding: file:line, description, severity, fix.

**Lens 1 — Correctness:**
Logic errors, edge cases, state management bugs, error propagation
failures. Does the code do what the plan says it should? Are there
inputs that produce wrong outputs? Paths where errors are swallowed?

**Lens 2 — Security:**
Auth boundaries, input validation, injection vectors (SQL, command,
template, prompt), secrets exposure, direct object reference
vulnerabilities. For each finding: describe the attack path.

**Lens 3 — Testing:**
Coverage gaps, weak assertions (tests that assert "no throw" without
checking the return value), missing edge cases, missing error-path
tests. For each gap: which test file, which scenario is missing.

**Lens 4 — Style:**
Naming quality, DRY violations, dead code, unnecessary complexity,
convention drift from the rest of the codebase. For each finding: the
specific improvement.

Severity scale:
- **P0:** Critical breakage or exploitable vulnerability. Must fix.
- **P1:** High-impact defect likely hit in normal use. Should fix.
- **P2:** Moderate issue. Fix if straightforward.
- **P3:** Low-impact. User's discretion.

Fix all P0 and P1 findings. Run tests after each fix. P2/P3 are the
user's call.

**Gate:** Zero P0 or P1 findings remaining. Tests still green.

---

### Phase 6: Ship

**Mode:** CAVE (just do it)

**Instructions:**

1. Version bump if the project uses semver
2. CHANGELOG entry: what changed, why it matters, in one line
3. Create PR with:
   - Meaningful title (imperative: "Add X" not "Added X")
   - Body: 2-3 bullet summary + test plan
4. Push and merge (or request user approval for merge)
5. If deployed: verify production — page loads, feature works, no
   console errors. Run a smoke test if one exists.

**Gate:** PR merged. If the project deploys: production verified.

---

### Phase 7: Compound

**Mode:** MED (structured reflection)

**Instructions:**

Close the loop. This is the compounding mechanism — each cycle leaves
the project's documentation sharper and the next cycle faster.

1. **Retro.** Three bullets:
   - What worked well this cycle
   - What didn't work or surprised us
   - What to change next time

2. **Handoff.** For the next session (or the next human):
   - Where we are now
   - What's next
   - What's blocked

3. **CONTEXT.md update.** If new domain terms emerged during the build
   that aren't yet in CONTEXT.md, add them now. Every cycle should
   leave CONTEXT.md more complete than it was.

4. **Deferred ADRs.** If architectural decisions were made during
   execution (Phase 4) that weren't captured in the spec (Phase 2),
   write them now. One paragraph each.

**Gate:** Retro exists. Handoff exists. CONTEXT.md is current.

The retro feeds the next cycle's Phase 1. The handoff feeds the next
session's context load. The CONTEXT.md updates compound across every
cycle for the life of the project.

---

## Quick reference

```
Phase 1: Ideate   [FULL]  → problem statement
Phase 2: Spec     [FULL]  → scope + success criteria + CONTEXT.md
Phase 3: Plan     [MED]   → implementation units with test scenarios
Phase 4: Execute  [CAVE]  → code + tests + commits
Phase 5: Review   [MED]   → findings report + fixes
Phase 6: Ship     [CAVE]  → PR + merge + verify
Phase 7: Compound [MED]   → retro + handoff + CONTEXT.md
```

## Shortcuts

Not every task needs all 7 phases:

- **Bug fix:** Phase 1 (state the bug) → Phase 4 (regression test +
  fix) → Phase 5 (review) → Phase 6 (ship). Skip 2, 3, 7.
- **Small feature (<200 LOC):** Phase 2 (quick scope) → Phase 3
  (quick plan) → Phase 4 → Phase 5 → Phase 6. Skip 1, 7.
- **Refactor:** Phase 3 (plan the refactor) → Phase 4 (execute with
  characterization tests first) → Phase 5 → Phase 6. Skip 1, 2, 7.

The discipline is knowing WHEN to skip, not always running all 7.
Skipping when scope is hazy → you build the wrong thing. Running all 7
on a typo fix → you stop shipping.
