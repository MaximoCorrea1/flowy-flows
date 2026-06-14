# FLOW.md — <<YOUR FLOW NAME>>

> <<WHAT THIS FLOW DELIVERS END TO END>>

**Before you fill anything in:** open `examples/wedding-photography-delivery/FLOW.md` and read it end-to-end — it shows this exact shape, fully worked. Then replace every `<<…>>` below with your own domain's phases, conditions, skills, and gates.

---

## For creators

You build **two** things:
1. **Your skills** — the `SKILL.md` files in `skills/` (the *how* — your domain expertise).
2. **A validated `FLOW.md`** — this router (the *when* — which skill fires at which moment).

Flowy provides everything else, **free**, the moment your Flow ships:
- **Enforcement** — a plugin hook injects your routing into the agent every turn.
- **Survives compaction** — routing stays active even in long conversations.
- **Activation & per-session state** — `/flowy activate <your-flow>` just works.

You do **not** write a hook, touch `settings.json`, or manage state. Build a good router + good skills; Flowy makes them mandatory.

*(This section is for you, the creator. Do not copy it into your own Flow — start the machine below at "How this works".)*

---

## How this works

Each skill in `skills/` is a standalone `SKILL.md` the agent reads and follows.
This FLOW.md is the routing layer — it decides WHEN each skill fires and what
"done" means for each step. The skills are the *how*; this file is the *when*.

### The engine gives you the universal contract — do NOT paste it

When your Flow is activated (`/flowy <slug>`), the Flowy engine (the activator's
routing obligation, read on activation and re-read after every compaction)
already supplies these for EVERY flow, for free. Never restate them in your file:

- **Announce ritual** — before acting on any message, the agent states one line:
  `Routing: <phase>/<leaf> — <reason>` (or `Routing: none`).
- **invoke/READ contract** — when a leaf says `→ invoke <name>`, the agent READS
  `skills/<name>/SKILL.md` fully, follows it, records the Gate's named artifact,
  then returns here for the next decision.
- **Host-integration** — this FLOW.md sits ABOVE the host's own rules; the host
  (its CLAUDE.md, project guards, safety rules) always wins. A flow never tells
  the agent to ignore or override the host.
- **Post-compaction re-read** — routing survives long sessions; the engine
  re-reads this file and the active phase is restated.

### Required core — every flow MUST have these

- `## Routing` — the decision tree: `condition? → invoke <skill>` + a **Gate**
  (a named artifact that must exist to advance).
- `## Priority on collision` — when >1 leaf matches, the resolve order.
- `## You are rationalizing if you think…` — the lies a hurried agent tells, each rebutted.
- `## Attribution` — credit + license.

### Optional building blocks — add only if your flow needs them

Include these for a **multi-phase pipeline**; omit them for a simple skill-router:

- `## Phases` — a named spine, each phase exiting on a HARD named-artifact gate.
- **Reasoning-mode marks** (FULL / CAVE / MED) — spend judgment where taste lives.
- **Loop-guard** — if the same Gate fails twice with no new information, STOP and
  surface the blocker; re-entry must carry new information.
- **Cross-node scratchpad** — write each Gate's artifact to one running scratchpad;
  downstream leaves READ it instead of re-deriving.
- **Parent-level fallbacks** — checked before phase leaves: brief changed →
  re-enter the invalidated phase; blocked on a third party → park with a resume
  condition; asked to advise (not do) → answer, don't start a phase.
- `## Compose with` (overlay flows) · `## Session-prime` (always-on context).

Everything below shows these in a worked, multi-phase shape. Keep what your
domain needs; delete the rest.

---

## Phases

<!-- ===================================================================== -->
<!-- LAYER 2 — DOMAIN SPINE. Rename these phases for your domain.          -->
<!-- Soft-ordered: default left-to-right, but any phase is re-enterable    -->
<!-- via the parent-level fallbacks above. Each phase has an ENTRY         -->
<!-- condition and an EXIT Gate phrased as "a NAMED ARTIFACT exists".      -->
<!-- Keep the "N. NAME — entry: … Gate: …" one-line shape so the validator -->
<!-- (and the next reader) can see the spine at a glance.                  -->
<!-- ===================================================================== -->

1. **<<PHASE 1 NAME>>** — entry: <<WHEN YOU ARE IN THIS PHASE>>. Gate: <<A NAMED ARTIFACT THAT MUST EXIST>>.
2. **<<PHASE 2 NAME>>** — entry: <<WHEN YOU ARE IN PHASE 2>>. Gate: <<A NAMED ARTIFACT THAT MUST EXIST>>.

---

## Routing

<!-- ===================================================================== -->
<!-- LAYER 3 — NESTED ECA LEAVES. This is the core router.                 -->
<!-- Shape of every leaf:   condition? → invoke <skill>                    -->
<!--                        Gate: <named artifact exists>                  -->
<!-- Soft gates (judgment, not a hard file) read: Gate: (soft) …          -->
<!-- The tree NESTS: Phase → Category → Condition → Action+Gate.           -->
<!-- ===================================================================== -->

```
USER MESSAGE RECEIVED
│
├─ INTAKE / TRIAGE  (always first)
│   └─ <<FIRST MESSAGE OR NEW REQUEST OF YOUR KIND>>
│       → invoke <<YOUR_INTAKE_SKILL>>
│       Gate: <<A NAMED ARTIFACT PROVING INTAKE IS DONE>>
│
├─ <<PHASE 1 NAME>>  (entry: <<WHEN YOU ARE IN THIS PHASE>>)
│   ├─ <<CATEGORY A A KIND OF WORK IN THIS PHASE>>
│   │   ├─ <<CONDITION THAT SELECTS THIS LEAF>>
│   │   │   → invoke <<YOUR_SKILL_A1>>
│   │   │   Gate: <<NAMED ARTIFACT EXISTS>>
│   │   └─ <<A SECOND CONDITION IN THIS CATEGORY>>
│   │       → invoke <<YOUR_SKILL_A2>>
│   │       Gate: <<NAMED ARTIFACT EXISTS>>
│   └─ <<CATEGORY B>>
│       └─ <<CONDITION>>
│           → invoke <<YOUR_SKILL_B1>>
│           Gate: <<NAMED ARTIFACT EXISTS>>
│
├─ <<PHASE 2 NAME>>  (entry: <<WHEN>>)
│   └─ <<CONDITION>>
│       → invoke <<YOUR_SKILL>>
│       Gate: <<NAMED ARTIFACT EXISTS>>
│
├─ DONE-CHECK  (before any "done"/"delivered" claim)
│   └─ → invoke <<YOUR_VERIFY_SKILL>>
│       Gate: <<EVIDENCE SHOWN BEFORE THE CLAIM>>
│
└─ DEFAULT / NO-MATCH  (always last)
    └─ <<NOTHING ABOVE FITS THIS MESSAGE>>
        → invoke <<YOUR_CLARIFY_SKILL>>
        Gate: (soft) ask one scoping question; announce Routing: none
```

---

## Priority on collision

When more than one leaf could fire on the same message, resolve in this order.
Most-broken state first; lifecycle order for ties; the default always loses.

1. **Blocked / waiting on external** — if work is parked on a client or vendor
   reply, surface that first; do not start new work on top of a known blocker.
2. **Scope changed** — a scope change invalidates downstream artifacts; handle
   it before continuing, or you build on a stale brief.
3. **Done-check / verify** — any "about to claim done" path runs its
   verification before the claim leaves your mouth.
4. **Lifecycle order** — otherwise advance in spine order:
   <<PHASE 1 NAME>> → <<PHASE 2 NAME>> → DONE-CHECK.
5. **Advisory** — a pure "explain / should I" question answers without starting
   a phase.
6. **Default / no-match** — loses to everything; only fires when nothing else
   matches.

---

## Standard Branches (paste-in)

<!-- ===================================================================== -->
<!-- Keep the 3 MANDATORY; add OFFERED as needed.                          -->
<!-- Reusable branch templates. The 3 MANDATORY ship in every Flow. The 4  -->
<!-- OFFERED are common enough that this blueprint includes all of them so  -->
<!-- you can see the shape; delete the ones your domain doesn't need.       -->
<!-- ===================================================================== -->

**Mandatory 1 — Intake / triage (first child of root).** Classify the message
before acting; never start mid-phase blind.

```
├─ New inquiry or first message of a new project?
│   → invoke intake-triage
│   Gate: signed-brief note exists; intent classified before any action
```

**Mandatory 2 — Done-check / verify (before any "delivered" claim).**

```
├─ About to claim done / delivered?
│   → invoke verify-delivery
│   Gate: delivered? evidence shown (receipt + count) before the claim
```

**Mandatory 3 — Default / no-match (last child of root).**

```
└─ Nothing matches / no branch fits?
    → invoke clarify-scope
    Gate: (soft) Routing: none — ask one scoping question, do not guess
```

**Offered A — Question-vs-work.** The human is asking me to advise or explain,
not to perform the work.

```
├─ Asking me to advise / explain (advisory, not do)?
│   → invoke advisory-answer
│   Gate: (soft) advice given; no phase silently started
```

**Offered B — Scope-change.** The brief changed mid-stream.

```
├─ Scope change — brief changed after a phase completed?
│   → invoke rebrief
│   Gate: change logged; re-enter the phase the change invalidates
```

**Offered C — Blocked-on-external.** Parked waiting on someone else.

```
├─ Blocked / waiting on a client or vendor reply (external dependency)?
│   → invoke park-and-resume
│   Gate: blocker named, resume condition set; park, don't fake progress
```

**Offered D — Review-loop.** Feedback came back and must be re-checked.

```
├─ Review feedback came back on the edits?
│   → invoke edit-review
│   Gate: review feedback resolved; selects re-verified after redline
```

---

## Reasoning-mode legend

Not every node deserves the same depth of thought. Mark each leaf so the agent
spends judgment where taste matters and moves fast where it doesn't. **Every leaf
gets a mark; an unmarked leaf defaults to MED.**

- **FULL (taste-heavy — slow down, reason hard):** the leaves where craft and
  judgment live and a wrong call can't be un-rung downstream. Mark your
  taste-heavy leaf — `<<YOUR_TASTE_HEAVY_LEAF>>` — FULL and reason hard there.

- **CAVE (mechanical — fast, low ceremony):** rote, no-taste steps — copy,
  rename, batch-export, pure lookup. Mark your mechanical leaf —
  `<<YOUR_MECHANICAL_LEAF>>` — CAVE and move fast.

- **MED (structured, but not deep):** follow the checklist, confirm the
  artifact, move on. Mark your structured leaf —
  `<<YOUR_STRUCTURED_LEAF>>` — MED; this is also the default for any unmarked leaf.

**Soft gates are for LIVE steps, not phase exits.** A `Gate: (soft) …` is fine on
an in-progress leaf (a live, in-the-moment step where the artifact is judgment,
not a file). But a phase's EXIT gate must stay HARD — a real, named artifact in
the scratchpad. The spine above already does this (every phase exits on a hard
named artifact); preserve that when you swap in your domain.

---

## You are rationalizing if you think…

These are the lies a hurried agent tells. Write your own domain's versions — see
`examples/wedding-photography-delivery/FLOW.md` for vivid ones. Each left-side
rationalization gets a one-line rebuttal.

---

## Attribution

Skills in `skills/` are by **<<YOUR NAME>>** (link to your GitHub or site).
The FLOW.md routing layer is by **<<YOUR NAME>>**, licensed under **<<LICENSE>>**
(e.g. CC-BY-SA-4.0).

If you bundled skills from another author, credit each here with the original
project link and its license. The routing layer and the skills can have
different authors — say so plainly.
