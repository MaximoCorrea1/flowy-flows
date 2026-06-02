# _blueprint — Flowy Starter Flow (deep-tree format, v0.3.0)

Fork this to build a Flow that fires the right skill at the right moment — not
just a bag of skills, but a router that knows when and why each one fires.

---

## Your job vs. the platform's job

You build **two** things: your **skills** (`skills/*/SKILL.md`) and a **validated `FLOW.md`** router. Flowy provides the rest **free** — enforcement, per-session state, and surviving compaction. You never write a hook or touch `settings.json`.

---

## What a deep Flow is

A Flowy Flow has three layers. **Layer 1** is universal machinery you copy
verbatim: the invoke/READ contract, the host-integration line, the per-turn
announce ritual, the priority tie-break, and the loop guard. It is the same in
every Flow. **Layer 2** is your domain phase-spine: the ordered lifecycle stages
of your craft, each with a hard exit Gate (a named artifact that must exist
before you advance). **Layer 3** is nested decision-tree leaves — the actual
router: `condition → invoke <skill>` + a `Gate:` that names the checkable
artifact the agent must produce before moving on.

The payoff: instead of guessing which skill to run, the agent declares its route
out loud (`Routing: CAPTURE / card-offload — files are pulled, backup not
confirmed`), invokes the right skill, records the Gate artifact, and returns for
the next decision. Nothing drops.

---

## The fill-in ladder (L1 → L4)

This is the four-level pattern that turns a blank flow into a deep tree.
Fill only L1 + L4 and you have a valid shallow tree. Reach L3 and you have the
deep tree the validator rewards. Each row below shows **two domains** so you can
see the shape is domain-general.

> The rows below illustrate what *your* tree could look like — they are not a
> line-by-line description of this blueprint's own FLOW.md (which keeps each
> phase deliberately small as a starting point). Use the rows as a model, then
> open `FLOW.md` to see the shape wired end-to-end.

### L1 — PHASES: name your lifecycle stages

Name the ordered stages of your work and give each one a hard exit Gate — a
named artifact that must exist before you can enter the next stage.

| Domain | Phases (in order) + exit Gates |
|---|---|
| **Photography** | see `examples/wedding-photography-delivery` |
| **Marketing** | AUDIT (audit findings doc) → RESEARCH (audience + competitor brief) → CREATE (approved draft in CMS) → DISTRIBUTE (scheduled/published confirmation) → MEASURE (30-day performance report) |

In FLOW.md, these go in `## Phases` as numbered, one-line entries:
`N. **NAME** — entry: <when you're in this phase>. Gate: <named artifact>.`

### L2 — CATEGORIES: kinds of work within a phase

Within a phase, different types of work fork into different skills. Name the
categories that carve the phase into distinct subtrees.

| Domain | Phase | Categories |
|---|---|---|
| **Photography** | see `examples/wedding-photography-delivery` | see `examples/wedding-photography-delivery` |
| **Marketing** | CREATE | long-form content / short-form content / landing copy |

In FLOW.md, categories become the second-level branches under a phase node.
They don't invoke a skill directly — they funnel to L3 conditions below them.

### L3 — CONDITIONS: the yes/no question that selects the exact action

Within a category, a single yes/no condition selects which leaf fires. Write it
as a question the agent can answer by reading the conversation and the scratchpad.

| Domain | Category | Condition |
|---|---|---|
| **Photography** | see `examples/wedding-photography-delivery` | see `examples/wedding-photography-delivery` |
| **Marketing** | `long-form` leaf | Is there an existing approved outline, or does one need to be built first? |

Keep conditions binary and checkable. "Vaguely feels like X" is not a condition.

### L4 — ACTION + GATE: invoke the skill and name the done artifact

The leaf: `→ invoke <skill-name>` + a `Gate:` line that states a checkable
artifact (a file, a note, a count, a written confirmation). "Done" means the
Gate artifact is in the scratchpad — not "I think I'm done."

| Domain | Leaf | Action + Gate |
|---|---|---|
| **Photography** | see `examples/wedding-photography-delivery` | see `examples/wedding-photography-delivery` |
| **Marketing** | draft-longform | `→ invoke draft-longform` Gate: outline approved in writing + draft saved to CMS in draft state (not published) |

**Soft gates** — mark a gate `Gate: (soft) …` when the artifact is a judgment
call, not a file. Use sparingly; phase EXIT gates must stay hard.

---

## The 7 standard branches — keep 3, add the rest as needed

Every Flow ships with 3 **mandatory** branches and may include up to 4
**offered** branches. The validator WARNS if a mandatory branch is missing — it
does not hard-reject — but a Flow without all three stalls, claims false done,
or hallucinates routes.

**Mandatory 1 — Intake / triage (always the first child of the root).** Classify
the message before any phase work starts. Never begin mid-phase blind.

```
├─ New inquiry or first message of a new project?
│   → invoke intake-triage
│   Gate: intent classified and initial context captured before any action
```

**Mandatory 2 — Done-check / verify (before any "delivered" / "done" claim).**

```
├─ About to claim done / delivered?
│   → invoke verify-delivery
│   Gate: evidence shown (artifact + count confirmed) before the claim
```

**Mandatory 3 — Default / no-match (always the last child of the root).** Fires
only when nothing else matches; forces the agent to ask, not guess.

```
└─ Nothing matches / no branch fits?
    → invoke clarify-scope
    Gate: (soft) Routing: none — ask one scoping question; do not guess
```

**Offered A — Question-vs-work.** Human is asking for advice, not action.

```
├─ Asking me to advise / explain (not to do the work)?
│   → invoke advisory-answer
│   Gate: (soft) advice given; no phase silently started
```

**Offered B — Scope-change.** Brief changed after a phase completed.

```
├─ Scope change — brief changed after a phase completed?
│   → invoke rebrief
│   Gate: change logged; re-enter the phase the change invalidates
```

**Offered C — Blocked-on-external.** Parked waiting on someone else.

```
├─ Blocked / waiting on a client or vendor reply?
│   → invoke park-and-resume
│   Gate: blocker named, resume condition set; do not fake progress
```

**Offered D — Review-loop.** Feedback came back and must be re-checked.

```
├─ Review feedback came back?
│   → invoke edit-review
│   Gate: feedback resolved; output re-verified before continuing
```

Copy the paste-in blocks from `## Standard Branches` in FLOW.md into your tree.

---

## Gates: hard by default, soft by exception

A gate is `Gate: <artifact exists>`. The artifact must be in the scratchpad —
not assumed, not implied, not "basically there."

Mark a checkpoint the agent may pass on judgment with `Gate: (soft) …`.
Use soft gates only on in-progress leaves where the artifact is inherently
a judgment call (e.g. ticking a running checklist during an active shoot).
Phase EXIT gates must stay hard — a real, named artifact.

---

## Validate before submitting

Paste your `FLOW.md` at https://flowy.dev/create-a-flow/validate.

The validator checks:

- FLOW.md is a decision tree, not prose (hard failure)
- Skills referenced in the tree are bundled in `skills/` (hard failure)
- `LICENSE` file exists (hard failure)
- Unfilled `<<…>>` placeholders are rejected — replace every one before submitting (this fires on the validate page AND on submit)
- Override patterns (`ignore CLAUDE.md`, `override project instructions`) — auto-rejected
- Depth, phase coverage, gate coverage, branch coverage — these are **warnings**,
  not rejections. The validator advises; it doesn't block on deep-tree checks.
  The hard floor is: valid FLOW.md + skills bundled + license present.

---

## Submit

Two paths, both go through the same review:

- **In-app upload:** https://flowy.dev/me/flows/new (recommended for first-time creators)
- **GitHub PR:** open a PR to https://github.com/MaximoCorrea1/flowy-flows

Approved Flows ship in the next plugin release and appear on https://flowy.dev/listings.

---

## Constraints

- 10 files maximum in the bundle (use `skillIndex` in SKILL.md frontmatter for larger skill sets)
- 5MB maximum bundle size
- License must be CC-BY-SA-4.0, MIT, CC-BY-4.0, or CC0-1.0

---

## Questions

Open a discussion or issue at https://github.com/MaximoCorrea1/flowy-flows.
