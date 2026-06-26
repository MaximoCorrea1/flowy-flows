# FLOW.md: Engineering Discipline

> Carry a change from a raw issue through a sharpened model, a designed interface, a test-first build, a diagnosed fix, and a clean handoff, firing the right discipline at each step.

> Skills vendored from Matt Pocock (MIT) — see ATTRIBUTION.md. Routing by Flowy.

## Phases

1. **Triage** — entry: a new issue, bug report, or external PR lands. Gate: the item carries one category role and one state role, with an agent brief recorded when it moves to ready-for-agent.
2. **Model** — entry: the work introduces or disputes domain terms before any code. Gate: the resolved term is written to CONTEXT.md (and an ADR recorded when the decision is hard to reverse).
3. **Design** — entry: a module's interface or seam is being shaped. Gate: a chosen interface is recorded as deep (small surface, behaviour hidden) with its seam named.
4. **Build** — entry: a feature or bugfix is ready to implement. Gate: one passing test exists per behaviour, written before its code, green through the public interface.
5. **Diagnose** — entry: something is broken, throwing, failing, or slow. Gate: a regression test goes from red to green on the exact reported symptom (or the missing seam is recorded as the finding).
6. **Handoff** — entry: the session ends or work passes to another agent. Gate: a handoff document is written that references artifacts by path and names the next skills to invoke.

## Routing

```
USER MESSAGE
│
├─ INTAKE / TRIAGE (a fresh issue, bug, or external PR; do this first)
│   └─ classify intent and state before acting → invoke triage
│       Gate: one category role + one state role applied; agent brief recorded on ready-for-agent.
│
├─ MODEL the domain (Phase 2)
│   ├─ user introduces a term that fights the glossary, or a fuzzy/overloaded word? → invoke domain-modeling
│   │   Gate: the canonical term is written to CONTEXT.md.
│   └─ a hard-to-reverse, surprising trade-off just landed? → invoke domain-modeling
│       Gate: an ADR recording the decision and its alternatives exists in docs/adr/.
│
├─ DESIGN an interface (Phase 3)
│   ├─ user is shaping a module's surface or asking where a seam goes? → invoke codebase-design
│   │   Gate: the interface is recorded as deep (small surface, behaviour hidden) with its seam named.
│   └─ two or more interfaces worth comparing on depth? → invoke codebase-design
│       Gate: a recommended interface is chosen and its leverage recorded.
│
├─ BUILD test-first (Phase 4)
│   └─ user wants to build a feature or fix a bug in code? → invoke tdd
│       Gate: one failing test per behaviour was written before its code and is now green through the public interface.
│
├─ DIAGNOSE a defect (Phase 5)
│   ├─ user reports something broken, throwing, failing, or slow? → invoke diagnosing-bugs
│   │   Gate: a tight red-capable command reproduces the user's exact symptom (paste the invocation and output).
│   └─ the fix is in and you must lock it down? → invoke diagnosing-bugs
│       Gate: a regression test goes red→green on the minimised repro (or the absent seam is recorded as the finding).
│
├─ REVIEW-LOOP (feedback came back on a diagnosis or design) → invoke diagnosing-bugs
│   Gate: each redline is re-verified by re-running the Phase 5 loop, captured red→green.
│
├─ DONE-CHECK (before any claim that a build or fix is done) → invoke tdd
│   Gate: the full test set is run and its passing output is shown, not asserted.
│
├─ HANDOFF (session ending or passing the baton) → invoke handoff
│   Gate: a handoff document is written that references artifacts by path and names the next skills to invoke.
│
├─ ADVISE-ONLY (user is asking you to explain or recommend, not change code) → answer only
│   Gate: none; no artifact is produced for a pure question.
│
├─ SCOPE CHANGE (the brief or requirements changed mid-flight) → re-enter the matching phase
│   Gate: the superseded work is named and the new phase's entry condition is restated.
│
├─ BLOCKED (waiting on an external dependency, access, or a human decision) → park and name the blocker
│   Gate: the blocker and its resume condition are written down; no further phase advances until it clears.
│
└─ DEFAULT (no branch fits) → answer only, ask one scoping question
    Gate: none; resolve which phase the user is in before routing.
```

## Priority on collision

1. Blocked
2. Scope changed
3. Done-check
4. Lifecycle order (Triage → Model → Design → Build → Diagnose → Handoff)
5. Advisory
6. Default

## You are rationalizing if you think…

- "I can see the cause, I will fix it and add the test after." No. `diagnosing-bugs` Phase 1 says a red-capable command must exist and run before any hypothesis. Jumping to a fix without a loop is the exact failure the skill prevents.
- "I will write all the tests first, then make them pass." No. `tdd` calls that horizontal slicing — it produces tests of imagined behaviour. One test, one implementation, repeat.
- "The term is obvious from context, I will not bother updating CONTEXT.md." No. `domain-modeling` resolves the term inline the moment it crystallises; an unwritten decision is re-litigated next session.
- "This is a one-line issue, I will just mark it ready-for-agent and skip the brief." No. `triage` requires an agent brief on the ready-for-agent transition; a brief-less issue strands the next agent.


## Additional skills (also available)

The full upstream set is vendored in this Flow. The routing above sequences
the core lifecycle; these additional skills are available and fire when their
trigger matches. See ATTRIBUTION.md for the complete list and license.

### engineering

- `ask-matt`: Ask which skill or flow fits your situation. A router over the user-invoked skills in this repo.
- `grill-with-docs`: A relentless interview to sharpen a plan or design, which also creates docs (ADR's and glossary) as we go.
- `implement`: Implement a piece of work based on a PRD or set of issues.
- `improve-codebase-architecture`: Scan a codebase for deepening opportunities, present them as a visual HTML report, then grill through whichever one you pick.
- `prototype`: Build a throwaway prototype to flesh out a design, a runnable terminal app for state/business-logic questions, or several radically different UI variations toggleable from one route.
- `resolving-merge-conflicts`: Use when you need to resolve an in-progress git merge/rebase conflict.
- `setup-matt-pocock-skills`: Configure this repo for the engineering skills, set up its issue tracker, triage label vocabulary, and domain doc layout. Run once before first use of the other engineering skills.
- `to-issues`: Break a plan, spec, or PRD into independently-grabbable issues on the project issue tracker using tracer-bullet vertical slices.
- `to-prd`: Turn the current conversation into a PRD and publish it to the project issue tracker, no interview, just synthesis of what you've already discussed.

### misc

- `git-guardrails-claude-code`: Set up Claude Code hooks to block dangerous git commands (push, reset --hard, clean, branch -D, etc.) before they execute. Use when user wants to prevent destructive git operations, add git safety hooks, or block git push/reset in Claude Code.
- `migrate-to-shoehorn`: Migrate test files from `as` type assertions to @total-typescript/shoehorn. Use when user mentions shoehorn, wants to replace `as` in tests, or needs partial test data.
- `scaffold-exercises`: Create exercise directory structures with sections, problems, solutions, and explainers that pass linting. Use when user wants to scaffold exercises, create exercise stubs, or set up a new course section.
- `setup-pre-commit`: Set up Husky pre-commit hooks with lint-staged (Prettier), type checking, and tests in the current repo. Use when user wants to add pre-commit hooks, set up Husky, configure lint-staged, or add commit-time formatting/typechecking/testing.

### productivity

- `grill-me`: A relentless interview to sharpen a plan or design.
- `grilling`: Interview the user relentlessly about a plan or design. Use when the user wants to stress-test a plan before building, or uses any 'grill' trigger phrases.
- `teach`: Teach the user a new skill or concept, within this workspace.
- `writing-great-skills`: Reference for writing and editing skills well, the vocabulary and principles that make a skill predictable.

## Attribution

- `triage` by **Matt Pocock** (https://github.com/mattpocock/skills), MIT.
- `domain-modeling` by **Matt Pocock** (https://github.com/mattpocock/skills), MIT.
- `codebase-design` by **Matt Pocock** (https://github.com/mattpocock/skills), MIT.
- `tdd` by **Matt Pocock** (https://github.com/mattpocock/skills), MIT.
- `diagnosing-bugs` by **Matt Pocock** (https://github.com/mattpocock/skills), MIT.
- `handoff` by **Matt Pocock** (https://github.com/mattpocock/skills), MIT.
