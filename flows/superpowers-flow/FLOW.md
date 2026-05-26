# FLOW.md — Superpowers Flow

> The routing layer for superpowers skills. This file tells the agent
> WHEN to invoke WHICH skill. Without it, skills are suggestions the
> agent ignores. With it, skills are mandatory workflows.
>
> Skills by Jesse Vincent (https://github.com/obra/superpowers, MIT).
> FLOW.md routing by Flowy (https://flowy.dev).

---

## How this works

Every skill in `skills/` is a standalone SKILL.md file with instructions
the agent follows. This FLOW.md defines WHEN to read each one.

When the routing table says "invoke [skill-name]":
→ The agent reads `skills/[skill-name]/SKILL.md` in this directory
→ Follows its instructions completely
→ Returns to the FLOW.md routing for the next decision

The agent does NOT need superpowers installed as a plugin. The skills
are bundled right here.

---

## CLAUDE.md Integration

**Add this single line to your project's CLAUDE.md** to activate routing:

```
Read [path-to-this-flow]/FLOW.md at session start.
```

Replace `[path-to-this-flow]` with the actual path to this directory
(e.g., `flows/superpowers-flow`). The FLOW.md contains the full routing
table — no need to copy anything else. The agent reads it fresh each
session.

---

## Routing Logic

### Decision tree

```
USER MESSAGE RECEIVED
  │
  ├─ Session start / first message in a new session?
  │   → skills/using-superpowers/SKILL.md
  │   Note: fires ONCE to bootstrap skill awareness; skip on subsequent turns
  │
  ├─ New idea / feature / project?
  │   → skills/brainstorming/SKILL.md
  │   Gate: design exists before any code
  │
  ├─ Design exists, no implementation plan?
  │   → skills/writing-plans/SKILL.md
  │   Gate: plan with checkboxed tasks
  │
  ├─ Plan exists with unchecked tasks?
  │   ├─ 3+ tasks are independent?
  │   │   → skills/subagent-driven-development/SKILL.md
  │   └─ Otherwise
  │       → skills/executing-plans/SKILL.md
  │   Gate: all checkboxes checked, tests green
  │
  ├─ About to write implementation code?
  │   → skills/test-driven-development/SKILL.md
  │   Gate: failing test exists before implementation
  │
  ├─ Something is broken / erroring?
  │   → skills/systematic-debugging/SKILL.md
  │   Gate: root cause confirmed before fix
  │
  ├─ About to claim "done" / "fixed" / "passing"?
  │   → skills/verification-before-completion/SKILL.md
  │   Gate: verification command output proves claim
  │
  ├─ Code complete, need review?
  │   → skills/requesting-code-review/SKILL.md
  │   Gate: findings addressed
  │
  ├─ Review feedback received?
  │   → skills/receiving-code-review/SKILL.md
  │   Gate: every finding resolved
  │
  ├─ All tasks done, branch ready?
  │   → skills/finishing-a-development-branch/SKILL.md
  │   Gate: tests pass + integration choice made
  │
  ├─ Need parallel isolated branches?
  │   → skills/using-git-worktrees/SKILL.md
  │
  └─ Want to create a custom skill?
      → skills/writing-skills/SKILL.md
```

### Priority when multiple triggers match

0. **Session bootstrap** — using-superpowers fires once at session start, before any other routing
1. **Debugging** — broken takes precedence
2. **Verification** — pending completion claims take precedence
3. **TDD** — code-about-to-be-written takes precedence
4. **Planning** — no plan = plan first
5. **Brainstorming** — no design = design first
6. Everything else in natural order

### Before every turn

State your routing decision:
  `Routing: [skill-name] — [one-line reason]`
If no skill applies: `Routing: none — [reason]`

### You are rationalizing if you think:

- "This is too simple for brainstorming" → invoke it. 30 seconds.
- "I already know the plan" → invoke writing-plans. Write it down.
- "I'll write tests after" → invoke TDD. Tests first. Always.
- "It obviously works" → invoke verification. Run the command.
- "I can just fix this quickly" → invoke systematic-debugging. Evidence first.
- "The review will be fine" → invoke requesting-code-review.
- "They just asked a question, no skill needed" → if writing code to answer it, TDD fires.
- "I already invoked this skill earlier" → each task is a fresh invocation. Invoke again.
- "I need to ask for clarification first" → brainstorming handles clarification. Route there.

### Skills that compose internally

Some skills invoke other skills as part of their workflow:
- `subagent-driven-development` → dispatches workers that each follow
  `test-driven-development`
- `executing-plans` → follows `test-driven-development` for each
  code-bearing task
- `finishing-a-development-branch` → runs verification (tests must
  pass) before presenting options

The FLOW.md doesn't double-invoke. If you route to
`subagent-driven-development`, TDD happens inside each worker.

**Nested vs top-level invocation rule:**
The routing table is for TOP-LEVEL routing only (the first skill you
enter per action). When you are already inside a skill and that skill
references another skill, follow the referenced skill inline — do NOT
re-evaluate the routing table. Return to the outer skill when the inner
skill completes. This prevents TDD and executing-plans from triggering
each other in a loop.

---

## Full Feature Pipeline

For a complete feature from idea → shipped:

```
brainstorming
  │ gate: design document exists
  ▼
writing-plans
  │ gate: plan with checkboxed tasks
  ▼
executing-plans / subagent-driven-development
  │ (internally: test-driven-development per task)
  │ gate: all checkboxes checked, tests green
  ▼
verification-before-completion
  │ gate: evidence for every claim
  ▼
requesting-code-review
  │ gate: findings resolved
  ▼
finishing-a-development-branch
  │ gate: tests pass, integration choice made
  ▼
SHIPPED
```

### Shortcuts

| Task type | Pipeline | Skip |
|-----------|----------|------|
| Bug fix | debugging → TDD (regression test) → verification → review → finish | brainstorming, writing-plans |
| Small feature (<200 LOC) | writing-plans → executing-plans → verification → review → finish | brainstorming |
| Refactor | writing-plans → executing-plans → review → finish | brainstorming |
| Typo / config | fix → verification → finish | everything else |

**When skipping brainstorming:** the user's initial message serves as
the problem statement. `writing-plans` proceeds directly from that
message — no design doc required. The plan IS the spec.

---

## Per-Skill Detail

### brainstorming

**Fires when:** user describes a new idea, feature, or project. Creative-
intent language: "I want to build," "what if we," "new feature," "let's add."

**What it does:** asks clarifying questions one at a time, proposes 2-3
approaches with tradeoffs, presents design section by section, writes a
design doc, then transitions to writing-plans.

**Gate:** design document exists and user approved it.

**Skip when:** bug fixes, config changes, unambiguous small tasks.

---

### writing-plans

**Fires when:** spec or design exists and needs implementation breakdown.

**What it does:** reads the spec, breaks into checkboxed implementation
units with file paths, approach, test scenarios, and verification per unit.

**Gate:** plan exists and user approved it.

---

### executing-plans

**Fires when:** plan has unchecked tasks, work is serial (tasks depend
on each other or share files).

**What it does:** works through tasks in order. Each task: read context →
implement → test → commit → mark done. Internally follows TDD for
code-bearing tasks.

**Gate:** all checkboxes checked, all tests green.

---

### subagent-driven-development

**Fires when:** plan has 3+ independent tasks (no shared files, no
sequential dependency). Parallel execution is faster.

**What it does:** dispatches one subagent per task with the task's goal,
files, approach, and test scenarios. Workers run in parallel. Orchestrator
integrates results.

**Gate:** all workers done, all tests green, no conflicts.

**Don't use when:** tasks share files or depend sequentially.

---

### dispatching-parallel-agents

**Fires when:** need ad-hoc parallel work outside a plan (research,
scanning, variant generation).

**What it does:** provides the dispatch pattern — how to spawn agents,
what context to give each, how to collect results.

---

### test-driven-development

**Fires when:** agent is about to write ANY implementation code.

**What it does:** RED → GREEN → REFACTOR:
1. Write failing test
2. Confirm it fails
3. Write minimal code to pass
4. Confirm it passes
5. Refactor if needed
6. Commit

**THIS IS THE MOST IMPORTANT SKILL.** Vibe-coding = code without tests.
TDD = the antidote. Fires on EVERY code-bearing task.

**Skip for:** pure config, docs, styling-only changes.

---

### systematic-debugging

**Fires when:** something is broken and the cause isn't obvious.

**What it does:** 4-phase structured debugging: reproduce → minimize →
hypothesize → instrument → fix + regression test.

**Gate:** root cause confirmed in writing before fix is attempted.

**Skip for:** obvious typos, missing imports where the error names the fix.

**If the broken code has no existing test coverage:** write the
regression test as the FIRST step of the TDD phase —
characterization-test-first, not red-green-refactor. Capture the
current (broken) behavior in a failing test, then fix until it passes.

---

### verification-before-completion

**Fires when:** agent is about to claim ANYTHING is done, fixed, passing,
complete, or working.

**The iron law:** No completion claims without fresh verification evidence.
If you haven't run the command in THIS message, you cannot claim it passes.

**No exceptions.** "I'm confident" ≠ evidence. Run the command.

---

### requesting-code-review

**Fires when:** implementation complete, needs review before merge.

**What it does:** two-stage review — agent self-reviews, then presents
structured findings to user.

**Gate:** findings addressed or accepted.

---

### receiving-code-review

**Fires when:** review feedback received (from human, agent, or CI).

**What it does:** processes each finding, categorizes by severity,
addresses in priority order, re-runs tests after fixes.

**Gate:** every finding resolved or explicitly deferred.

---

### finishing-a-development-branch

**Fires when:** all tasks done, branch ready to land.

**What it does:** verify tests → detect environment → present 4 options
(merge / PR / keep / discard) → execute choice → cleanup worktree.

**Gate:** tests pass + user chose integration option.

---

### using-git-worktrees

**Fires when:** need parallel isolated branches.

**What it does:** creates worktree with fresh branch, sets up working
directory, advises on when worktrees help vs hurt.

---

### writing-skills

**Fires when:** user wants to create a custom project-specific skill.

**What it does:** guides skill authoring — name, trigger, instructions,
red flags, common mistakes.

---

### using-superpowers

**Fires when:** session start, or agent is unsure how the skill system
works.

**What it does:** explains invocation protocol, lists available skills,
establishes that skill usage is mandatory.

**Fires at session start** to bootstrap skill awareness.

---

## Anti-Patterns

| Without routing | With routing |
|---|---|
| Code without tests | TDD fires before every code change |
| Fix without diagnosis | Debugging fires before any fix |
| Ship without review | Review fires before branch landing |
| Claim without evidence | Verification fires before every claim |
| Build without spec | Brainstorming fires on new ideas |
| Code without plan | Writing-plans fires after spec |
| End without cleanup | Finishing fires when tasks complete |

---

## Attribution

Skills in `skills/` are from [superpowers](https://github.com/obra/superpowers)
by [Jesse Vincent](https://github.com/obra), licensed under the MIT License.
See LICENSE in this directory.

The FLOW.md routing document is by [Flowy](https://flowy.dev), licensed
under CC-BY-SA-4.0.
