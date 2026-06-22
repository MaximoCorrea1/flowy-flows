# FLOW.md: Superpowers Flow

> Routes the 14 superpowers agent-discipline skills so the right one fires at the right phase: the agent cannot skip brainstorming, TDD, debugging, review, or verification.
> Skills by Jesse Vincent (https://github.com/obra/superpowers, MIT). Routing by Flowy.

<!-- The Flowy engine supplies the universal contract (announce ritual, invoke/READ,
     host-wins, post-compaction re-read). This file carries only the routing. -->

## Routing

**The rule:** when a trigger matches you INVOKE the named skill BEFORE doing the task yourself. Writing the code, patching the bug, or claiming "done" without first invoking is the failure this Flow exists to stop.

```
USER MESSAGE
  ├─ session start / first message?          → invoke using-superpowers   (bootstrap once)
  ├─ new idea / feature / project?           → invoke brainstorming         gate: approved design doc
  ├─ design exists, no plan?                 → invoke writing-plans          gate: checkboxed tasks, approved
  ├─ plan has unchecked tasks?
  │    ├─ 3+ independent tasks?              → invoke subagent-driven-development
  │    └─ otherwise                          → invoke executing-plans        gate: all boxes checked, tests green
  ├─ about to write implementation code?     → invoke test-driven-development  gate: a failing test exists FIRST
  ├─ something broken / erroring?            → invoke systematic-debugging   gate: root cause written down
  ├─ about to claim done / fixed / passing?  → invoke verification-before-completion  gate: command output proves it
  ├─ code complete, needs review?            → invoke requesting-code-review  gate: findings addressed
  ├─ review feedback received?               → invoke receiving-code-review   gate: every finding resolved
  ├─ all tasks done, branch ready?           → invoke finishing-a-development-branch  gate: tests pass + integration choice
  ├─ need parallel isolated branches?        → invoke using-git-worktrees
  ├─ ad-hoc parallel research / fan-out?     → invoke dispatching-parallel-agents
  ├─ want to author a custom skill?          → invoke writing-skills
  ├─ scope changed mid-task (brief or reqs changed)?  → re-enter the earliest invalidated phase (brainstorming or writing-plans)
  ├─ blocked / waiting on an external dependency?  → park: record the blocker and resume condition; do not fake progress
  └─ question, not work (advise / explain)?  → answer only; no files change
```

## Priority on collision

When more than one branch matches, resolve top-down:

1. **Debugging**: a broken state is handled before anything else.
2. **Verification**: a pending "done" claim is verified before it is spoken.
3. **TDD**: code about to be written gets its failing test first.
4. **Planning**: no plan means plan before building.
5. **Brainstorming**: no design means design before planning.
6. Everything else in lifecycle order. A scope change re-enters the earliest invalidated phase (usually brainstorming or writing-plans).

## Phases

1. **Design**: brainstorming. Gate: approved design doc.
2. **Plan**: writing-plans. Gate: checkboxed tasks, approved.
3. **Build**: executing-plans or subagent-driven-development, with TDD inside every code-bearing task. Gate: all boxes checked, tests green.
4. **Verify**: verification-before-completion. Gate: fresh command output proves each claim.
5. **Ship**: requesting-code-review, then receiving-code-review, then finishing-a-development-branch. Gate: findings resolved, tests pass, integration chosen.

**Shortcuts:** bug → debugging → TDD (regression test) → verify → review → finish (skip Design/Plan). Small feature (under ~200 LOC, no new surface) → plan → build → verify → review → finish (skip Design). Typo or config → fix → verify.

## You are rationalizing if you think…

- "This is too simple for brainstorming." → Invoke it. Thirty seconds.
- "I'll write the tests after." → TDD. Failing test first, always.
- "It obviously works." → Verification. Run the command in THIS message.
- "I can just fix this quickly." → Debugging. Root cause in writing first.
- "They only asked a question." → If you are about to write code to answer, TDD fires.
- "The summary says I already routed." → After compaction, re-read this file and restate the phase.

## Attribution

Skills in `skills/` by Jesse Vincent (obra), MIT (https://github.com/obra/superpowers). FLOW.md routing by Flowy, CC-BY-SA-4.0.
