# FLOW.md — Engineering Without Vibe Coding

> The routing layer for superpowers. This file tells the agent WHEN to
> invoke WHICH skill. Without it, skills are suggestions. With it,
> skills are mandatory workflows.

## Goal

Make superpowers skills auto-invoke based on context. The agent checks
this routing table before every action. When a trigger matches, the
agent MUST invoke the skill via the Skill tool. No exceptions.

## Requires

- **superpowers** plugin installed (MIT, https://github.com/obra/superpowers)
- Install: `npx skills@latest add obra/superpowers-marketplace`

If a skill invocation fails with "Unknown skill," superpowers is not
installed. Stop and tell the user to install it.

---

## CLAUDE.md Integration

Paste this block into your project's CLAUDE.md to activate the routing.
The routing is active whenever this text is in the agent's context.

```markdown
## Skill routing (Engineering Without Vibe Coding)

The agent MUST check this routing table before every action. When a
trigger condition matches, invoke the skill via the Skill tool. Do NOT
simulate skill output inline. Do NOT skip invocation. Do NOT rationalize
("this is too simple for a skill" — invoke it anyway).

### Mandatory routing table

| Trigger | Invoke | Why |
|---------|--------|-----|
| User describes new idea, feature, or unclear scope | `superpowers:brainstorming` | Ideate before implementing |
| Spec/design approved, need implementation tasks | `superpowers:writing-plans` | Plan before coding |
| Plan exists with checkboxed tasks, ready to build | `superpowers:executing-plans` | Execute task by task |
| 3+ tasks are independent and touch different files | `superpowers:subagent-driven-development` | Parallelize |
| About to write ANY implementation code | `superpowers:test-driven-development` | RED → GREEN → REFACTOR |
| Something is broken, error source unclear | `superpowers:systematic-debugging` | Diagnose before fixing |
| About to claim work is "done", "fixed", or "passing" | `superpowers:verification-before-completion` | Evidence before claims |
| Implementation complete, want feedback | `superpowers:requesting-code-review` | Structured review |
| Received code review feedback | `superpowers:receiving-code-review` | Process feedback properly |
| All tasks complete, branch ready to land | `superpowers:finishing-a-development-branch` | Clean completion |
| Need parallel isolated branches | `superpowers:using-git-worktrees` | Worktree isolation |
| Need to fan-out work to parallel agents | `superpowers:dispatching-parallel-agents` | Parallel dispatch |
| Want to create a reusable skill | `superpowers:writing-skills` | Skill authoring |

### Red flags — you are rationalizing if you think:

- "This is too simple for brainstorming" — invoke it. 30 seconds.
- "I already know the plan" — invoke writing-plans. Write it down.
- "I'll write tests after" — invoke TDD. Tests first. Always.
- "It obviously works" — invoke verification. Run the command.
- "I can just fix this quickly" — invoke systematic-debugging.
  Print the error. Read it. Then fix.
- "The review will be fine" — invoke requesting-code-review.
  Two-stage review catches what you miss.

### State the routing decision

At the start of every turn, state which skill you're routing to:
`Routing: [skill-name] because [one-line reason]`

If no skill applies (rare — think hard), state:
`Routing: none — [one-line reason]`
```

---

## Routing Logic — Detailed

### How the agent decides which skill to invoke

The routing table above is the quick reference. Below is the detailed
decision logic the agent follows.

```
USER MESSAGE RECEIVED
  │
  ├─ Does the message describe a NEW idea, feature, or project?
  │   YES → invoke superpowers:brainstorming
  │         Gate: design exists before any code
  │
  ├─ Does a design/spec exist but no implementation plan?
  │   YES → invoke superpowers:writing-plans
  │         Gate: plan with checkboxed tasks exists
  │
  ├─ Does a plan exist with unchecked tasks?
  │   │
  │   ├─ Are 3+ tasks independent (no shared files)?
  │   │   YES → invoke superpowers:subagent-driven-development
  │   │         (which internally dispatches parallel agents)
  │   │
  │   └─ Otherwise
  │       YES → invoke superpowers:executing-plans
  │             (serial task execution)
  │
  ├─ Is the agent about to write implementation code?
  │   YES → invoke superpowers:test-driven-development
  │         Gate: failing test exists before implementation
  │
  ├─ Is something broken / failing / erroring?
  │   YES → invoke superpowers:systematic-debugging
  │         Gate: root cause identified before fix attempted
  │
  ├─ Is the agent about to claim anything is complete?
  │   YES → invoke superpowers:verification-before-completion
  │         Gate: verification command output proves the claim
  │
  ├─ Is implementation complete, needs review?
  │   YES → invoke superpowers:requesting-code-review
  │         Gate: review findings addressed or accepted
  │
  ├─ Has review feedback been received?
  │   YES → invoke superpowers:receiving-code-review
  │         Gate: every finding resolved or explicitly deferred
  │
  ├─ Are all tasks done, branch ready to land?
  │   YES → invoke superpowers:finishing-a-development-branch
  │         Gate: tests pass + integration choice made
  │
  ├─ Does the work need isolated parallel branches?
  │   YES → invoke superpowers:using-git-worktrees
  │
  └─ Does the user want to create a new skill?
      YES → invoke superpowers:writing-skills
```

### Multiple triggers can match

When multiple triggers match simultaneously, use this priority:

1. **Debugging** — if something is broken, fix it first
2. **Verification** — if a completion claim is pending, verify first
3. **TDD** — if code is about to be written, test first
4. **Planning** — if no plan exists, plan first
5. **Brainstorming** — if no design exists, design first
6. Everything else in natural order

### Skills that compose

Some skills invoke other skills internally:
- `subagent-driven-development` dispatches workers that each invoke
  `test-driven-development`
- `executing-plans` goes task-by-task, invoking `test-driven-development`
  for each code-bearing task
- `finishing-a-development-branch` invokes `verification-before-completion`
  internally (tests must pass before presenting options)

The FLOW.md doesn't need to double-invoke. If you route to
`subagent-driven-development`, TDD happens inside each worker.

---

## Phase Pipeline (full feature flow)

For a complete feature from idea → shipped, the natural phase ordering is:

```
Phase 1: brainstorming
  │ gate: design document exists
  ▼
Phase 2: writing-plans
  │ gate: plan with checkboxed tasks exists
  ▼
Phase 3: executing-plans / subagent-driven-development
  │ (internally: test-driven-development per task)
  │ gate: all checkboxes checked, tests green
  ▼
Phase 4: verification-before-completion
  │ gate: verification evidence for every claim
  ▼
Phase 5: requesting-code-review
  │ gate: review clean or findings resolved
  ▼
Phase 6: finishing-a-development-branch
  │ gate: tests pass, integration choice made
  ▼
DONE
```

### Shortcuts (abbreviated pipelines)

Not every task needs all phases:

| Task type | Phases | Skip |
|-----------|--------|------|
| Bug fix | debugging → TDD (regression test) → verification → review → finish | brainstorming, writing-plans |
| Small feature (<200 LOC) | writing-plans → executing-plans → verification → review → finish | brainstorming |
| Refactor | writing-plans → executing-plans (characterization tests first) → review → finish | brainstorming |
| Typo / config | direct fix → verification → finish | everything else |

The discipline: know WHEN to skip. Skip when scope is clear. Don't skip
when scope is hazy — that's how vibe-coding starts.

---

## Per-Skill Routing Details

### 1. brainstorming

**Fires when:** user describes a new idea, feature, or project. Any
message containing "I want to build," "what if we," "new feature,"
"let's add," or similar creative-intent language.

**What the skill does:** asks clarifying questions one at a time,
proposes 2-3 approaches with tradeoffs, presents a design section by
section, writes a design doc.

**Gate to next phase:** design document exists and user approved it.
The skill's terminal state is invoking `writing-plans`.

**Do NOT invoke brainstorming for:** bug fixes, config changes, small
tasks with unambiguous scope, or when the user explicitly says "skip
brainstorming, here's what I want."

---

### 2. writing-plans

**Fires when:** a spec or design exists and needs to be broken into
implementation tasks. Any message referencing a spec, design doc, or
requirements that says "implement this," "plan this," "break this down."

**What the skill does:** reads the spec, maps file structure, breaks
into checkboxed implementation units with test scenarios per unit.

**Gate to next phase:** plan with checkboxed tasks exists and user
approved it. The skill saves to `docs/superpowers/plans/`.

**Do NOT invoke for:** tasks that are already a single obvious unit
(no planning needed for "fix the typo on line 42").

---

### 3. executing-plans

**Fires when:** a plan exists with unchecked tasks and the work will
proceed serially (tasks depend on each other or touch shared files).

**What the skill does:** works through tasks in order. For each: reads
context, implements, tests, commits. Marks tasks done as it goes.

**Internally invokes:** `test-driven-development` for each code-bearing
task. `verification-before-completion` before marking tasks done.

**Gate:** all checkboxes checked, all tests green.

---

### 4. subagent-driven-development

**Fires when:** a plan has 3+ tasks that are genuinely independent (no
shared files, no sequential dependency). Parallel execution is faster.

**What the skill does:** dispatches one subagent per task. Each worker
gets the task's goal, files, approach, and test scenarios. Workers run
in parallel. The orchestrator integrates results.

**Internally invokes:** `test-driven-development` inside each worker.
`verification-before-completion` between waves.

**Gate:** all workers report done, all tests green, no merge conflicts.

**Do NOT use when:** tasks share files (they'll conflict), the plan has
fewer than 3 tasks, or tasks depend sequentially on each other.

---

### 5. dispatching-parallel-agents

**Fires when:** you need to fan-out work to multiple agents for
non-plan work (research, file scanning, variant generation).

**What the skill does:** provides the dispatch pattern — how to spawn
parallel agents, what context to give each, how to collect results.

**This is the low-level parallel primitive.** `subagent-driven-development`
uses it internally. Invoke directly only when you're NOT working from a
plan and need ad-hoc parallelism.

---

### 6. test-driven-development

**Fires when:** the agent is about to write ANY implementation code.
This includes: new functions, bug fixes, refactors that change behavior,
new endpoints, new components.

**What the skill does:** enforces RED → GREEN → REFACTOR:
1. Write the failing test first
2. Run it — confirm it fails
3. Write the minimal code to pass
4. Run it — confirm it passes
5. Refactor if needed
6. Commit

**THIS IS THE MOST IMPORTANT SKILL IN THE TABLE.** Vibe-coding is
"write code without tests." TDD is the antidote. This skill fires on
EVERY code-bearing task, inside every plan execution, inside every
parallel worker.

**Exceptions (skip TDD for):**
- Pure config (env vars, package.json)
- Documentation changes
- Styling-only changes (CSS, Tailwind)
- Scaffold with no behavior yet

For these, invoke `verification-before-completion` instead.

---

### 7. systematic-debugging

**Fires when:** something is broken and the cause is not obvious.
Error messages, failing tests, unexpected behavior, stack traces.

**What the skill does:** structured 4-phase debugging:
1. Reproduce the failure
2. Minimize to the simplest case
3. Hypothesize the root cause
4. Instrument to confirm the hypothesis
5. Fix + regression test

**Gate:** root cause confirmed in writing before fix is attempted.
No "I think this might fix it" — evidence first.

**Do NOT invoke for:** obvious typos, missing imports, or errors where
the fix is immediately visible in the error message.

---

### 8. verification-before-completion

**Fires when:** the agent is about to claim ANYTHING is done, fixed,
passing, complete, or working. This includes: "tests pass," "build
succeeds," "bug fixed," "feature complete," "ready for review."

**The iron law:** NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION
EVIDENCE. If you haven't run the command in THIS message, you cannot
claim it passes.

**What the skill does:** forces the agent to:
1. Identify what command proves the claim
2. Run it (fresh, complete)
3. Read the full output
4. Verify the output supports the claim
5. ONLY THEN make the claim

**This skill has no exceptions.** "I'm confident" is not evidence.
"Should work now" is not evidence. Run the command. Read the output.
Then claim.

---

### 9. requesting-code-review

**Fires when:** implementation is complete and the code needs review
before merge.

**What the skill does:** two-stage review:
1. Agent reviews its own work (catches obvious issues)
2. Agent presents structured findings to the user

**Gate:** review findings addressed or explicitly accepted by the user.

---

### 10. receiving-code-review

**Fires when:** review feedback has been received (from a human, from
another agent, from a CI check).

**What the skill does:** processes each finding, categorizes by severity,
addresses in priority order, re-runs tests after each fix.

**Gate:** every finding is resolved (fixed, deferred with reason, or
explicitly rejected with rationale).

---

### 11. finishing-a-development-branch

**Fires when:** all tasks are done, tests pass, and the branch needs
to be integrated.

**What the skill does:**
1. Verify tests pass (blocks if they don't)
2. Detect environment (normal repo vs worktree)
3. Present 4 options: merge locally, create PR, keep as-is, discard
4. Execute the chosen option
5. Clean up worktree if applicable

**Gate:** tests pass + user chose an integration option + cleanup done.

---

### 12. using-git-worktrees

**Fires when:** you need isolated parallel branches — working on two
features simultaneously, or want to keep the main branch clean while
experimenting.

**What the skill does:** creates a git worktree with a fresh branch,
sets up the working directory, advises on when worktrees help vs hurt.

---

### 13. writing-skills

**Fires when:** the user wants to create a custom skill for a
pattern specific to their project.

**What the skill does:** guides skill authoring — name, description,
trigger condition, instructions, red flags, common mistakes.

---

### 14. using-superpowers

**Fires when:** the agent is unsure how the skill system works, or
at session start to bootstrap skill awareness.

**What the skill does:** explains the skill invocation protocol,
lists available skills, establishes that skill usage is mandatory.

**This is the meta-skill.** It should fire at the START of every
session. If the agent doesn't check for skills before its first action,
the routing table isn't loaded.

---

## Anti-Patterns

The routing exists to prevent these:

| Anti-pattern | What happens without routing | Routing fix |
|---|---|---|
| **Code without tests** | Agent writes code, skips tests, claims "done" | TDD fires before every code change |
| **Fix without diagnosis** | Agent guesses at the cause, applies random fixes | Debugging fires before any fix attempt |
| **Ship without review** | Agent pushes unreviewed code | Review fires before branch landing |
| **Claim without evidence** | Agent says "tests pass" without running them | Verification fires before every claim |
| **Build without spec** | Agent starts coding before understanding the problem | Brainstorming fires on new ideas |
| **Code without plan** | Agent writes code without knowing what it's building | Writing-plans fires after spec |
| **End without cleanup** | Branch lives forever, worktree not cleaned | Finishing fires when tasks complete |

---

## How This Flow Relates to Your Project's FLOW.md

If your project already has a root FLOW.md (like the one in the Flowy
repo), this Flow's routing table SUPPLEMENTS it — it doesn't replace it.

Your project's FLOW.md defines PROJECT-SPECIFIC routing (what to do
when working on THIS codebase). This Flow's routing table defines
SKILL-SPECIFIC routing (when to invoke which superpowers skill).

Both can coexist in your CLAUDE.md:
```
Read these files at session start:
1. CONTEXT.md — domain language
2. FLOW.md — project-specific workflow
3. [this Flow's CLAUDE.md integration block]
```

---

## Versioning

This Flow follows the Flow Folder Standard v0.1
(https://github.com/MaximoCorrea1/flowy/blob/main/docs/standards/flow-folder-standard.md).

Changes to the routing table bump the minor version. Breaking changes
to the CLAUDE.md integration block bump the major version.
