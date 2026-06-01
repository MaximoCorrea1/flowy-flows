# FLOW.md — Wedding Photography Delivery

> From signed inquiry to a delivered gallery — nothing dropped.

<!--
  This is the Flowy BLUEPRINT. It is a fully-worked, deep example you copy
  and adapt. The domain here is WEDDING PHOTOGRAPHY on purpose: it proves the
  pattern is domain-general. Your Flow might be cold-email, grant-writing,
  inspection reports, or anything else — the SHAPE is the same.

  Three layers, top to bottom:
    LAYER 1  Universal machinery   — copy VERBATIM. Do not edit.
    LAYER 2  Domain phase spine     — rename phases for your domain (<<EDIT>>).
    LAYER 3  Nested decision leaves — Phase → Category → Condition → Action+Gate.

  Read it once end-to-end before you change anything.
-->

---

## How this works

<!-- ===================================================================== -->
<!-- LAYER 1 — UNIVERSAL MACHINERY. COPY THIS SECTION VERBATIM.            -->
<!-- Every Flow needs exactly this contract. Do not reword the rules.      -->
<!-- ===================================================================== -->

Each skill in `skills/` is a standalone `SKILL.md` the agent reads and follows.
This FLOW.md is the routing layer — it decides WHEN each skill fires and what
"done" means for each step. The skills are the *how*; this file is the *when*.

**The invoke/READ contract — copy verbatim.** When a leaf below says
`→ invoke <name>`:

1. READ `skills/<name>/SKILL.md` in this folder, top to bottom.
2. FOLLOW its instructions completely — do not summarize or skip.
3. RECORD the named artifact the Gate asks for (a file, a note, a decision)
   in the cross-node scratchpad before you move on.
4. RETURN here for the next routing decision.

**Host-integration line — copy verbatim.** This FLOW.md sits *above* the host
agent's own rules. When the host has a global instruction (its CLAUDE.md, a
project guard, a safety rule), the host rule wins. This file never tells the
agent to ignore, override, or disregard the host — it only chooses which skill
to read next.

**The per-turn announce ritual — copy verbatim.** Before acting on ANY user
message, state one line out loud:

  `Routing: <PHASE> / <leaf> — <one-line reason>`

If nothing matches: `Routing: none — <reason>`. The announce is not decoration;
it is how you (and the human) catch a mis-route before work happens.

**Priority tie-break — copy verbatim.** When two leaves both match, resolve in
the order given in *Priority when multiple triggers match* below. Most-broken
state is handled first; the default branch always loses.

**Parent-level fallbacks (declared once) — copy verbatim.** These are checked
on EVERY turn, before the phase-specific leaves, and they may re-enter an
earlier phase:

- The client changed the brief? → re-enter the phase the change invalidates.
- You are blocked waiting on the client or a third party? → park, set a resume
  condition, do not fake progress.
- The human is asking you to advise, not to do the work? → answer; do not
  silently start a phase.

**Nested-vs-top-level loop guard — copy verbatim.** A leaf may send you back to
an earlier phase (re-shoot, re-cull, re-edit). That is legal. An *unbounded*
loop is not: if the same gate fails twice with no new information, STOP and
surface the blocker to the human instead of re-running the same step a third
time. Re-entry must carry new information; repetition without it is a stall.

**Cross-node scratchpad rule — copy verbatim.** Artifacts produced by one leaf
(the signed brief, the approved shot list, the cull selects, the gallery link)
are written to a single running scratchpad for this session. Downstream leaves
READ from the scratchpad rather than re-deriving. If a Gate's artifact is not
in the scratchpad, its phase is not done — no matter how it *feels*.

<!-- ===================================================================== -->
<!-- END LAYER 1. Everything below is yours to adapt.                      -->
<!-- ===================================================================== -->

---

## Phases

<!-- ===================================================================== -->
<!-- LAYER 2 — DOMAIN SPINE. <<EDIT THESE PHASES FOR YOUR DOMAIN>>          -->
<!-- Soft-ordered: default left-to-right, but any phase is re-enterable    -->
<!-- via the parent-level fallbacks above. Each phase has an ENTRY         -->
<!-- condition and an EXIT Gate phrased as "a NAMED ARTIFACT exists".      -->
<!-- Keep the "N. NAME — entry: … Gate: …" one-line shape so the validator -->
<!-- (and the next reader) can see the spine at a glance.                  -->
<!-- ===================================================================== -->

1. **BRIEF** — entry: a new signed inquiry with no captured requirements yet. Gate: a signed-brief note exists (date, venue, must-have shots, family list, deliverable count).
2. **SHOOT-PLAN** — entry: the signed brief exists but no timeline/shot list yet. Gate: an approved shot list and a minute-by-minute day timeline exist, confirmed by the couple.
3. **CAPTURE** — entry: the shoot plan is approved and the event day has arrived. Gate: a verified card-offload note exists — every must-have shot accounted for, files backed up to two locations.
4. **CULL / EDIT** — entry: captured files are offloaded and backed up. Gate: a locked select set exists and every select is color-and-exposure corrected (retouching on the agreed subset only).
5. **DELIVER** — entry: the edited select set is locked. Gate: a delivered-gallery note exists — gallery link sent, download enabled, contract deliverable count met, client receipt confirmed.

---

## Decision tree

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
├─ INTAKE / TRIAGE  (always first — classify before you act)
│   │
│   ├─ New inquiry or first message of a new project?
│   │   → invoke intake-triage
│   │   Gate: a signed-brief note exists with date, venue, and must-haves
│   │
│   └─ Returning client, mid-project message?
│       → invoke scratchpad-read
│       Gate: current phase and last artifact recovered from the scratchpad
│
├─ PARENT FALLBACKS  (checked every turn, before phase leaves)
│   │
│   ├─ Human is asking me to advise/explain, not to do the work?
│   │   → invoke advisory-answer
│   │   Gate: (soft) question answered; no phase silently started
│   │
│   ├─ Brief changed — date moved, venue swapped, deliverables added?
│   │   → invoke rebrief
│   │   Gate: scope change logged; re-enter the phase the change invalidates
│   │
│   └─ Blocked waiting on client sign-off or a venue/vendor reply?
│       → invoke park-and-resume
│       Gate: blocker named, resume condition set, no faked progress
│
├─ BRIEF  (entry: new signed inquiry, no requirements captured)
│   │
│   ├─ Requirements not yet captured?
│   │   → invoke intake-triage
│   │   Gate: signed-brief note exists (date, venue, family list, count)
│   │
│   └─ Brief drafted but not confirmed by the couple?
│       → invoke brief-confirm
│       Gate: couple's written confirmation recorded in the scratchpad
│
├─ SHOOT-PLAN  (entry: signed brief exists, no plan yet)
│   │
│   ├─ No shot list yet?
│   │   → invoke shoot-planning
│   │   Gate: shot list drafted from must-haves and venue light notes
│   │
│   ├─ Shot list exists but no day timeline?
│   │   → invoke shoot-planning
│   │   Gate: minute-by-minute timeline exists (golden hour, formals, exit)
│   │
│   └─ Plan drafted, couple hasn't approved?
│       → invoke plan-review
│       Gate: couple approved the shot list and timeline in writing
│
├─ CAPTURE  (entry: plan approved, event day)
│   │
│   ├─ On the day, shooting in progress?
│   │   → invoke capture
│   │   Gate: (soft) running shot-list checklist kept; must-haves ticked live
│   │
│   └─ Cards pulled, files not yet secured?
│       → invoke card-offload
│       Gate: verified offload note — files backed up to two locations
│
├─ CULL / EDIT  (entry: files offloaded and backed up)
│   │
│   ├─ Not culled yet?
│   │   → invoke culling
│   │   Gate: locked select set exists (rejects flagged, no second pass pending)
│   │
│   ├─ Selects locked, color/exposure not corrected?
│   │   → invoke retouching
│   │   Gate: every select color-and-exposure corrected to house style
│   │
│   └─ Edits done — about to send. Did the human review feedback come back?
│       → invoke edit-review
│       Gate: review feedback resolved; selects re-verified after redline
│
├─ DELIVER  (entry: select set locked and edited)
│   │
│   ├─ Gallery not built/exported yet?
│   │   → invoke gallery-delivery
│   │   Gate: gallery built, downloads enabled, deliverable count met
│   │
│   └─ DONE-CHECK — about to claim delivered?
│       → invoke verify-delivery
│       Gate: delivered? client receipt confirmed and count verified before "done"
│
└─ DEFAULT / NO-MATCH  (always last — catch-all)
    │
    └─ Nothing above fits this message?
        → invoke clarify-scope
        Gate: (soft) ask one scoping question; announce Routing: none until it fits
```

---

## Priority when multiple triggers match

When more than one leaf could fire on the same message, resolve in this order.
Most-broken state first; lifecycle order for ties; the default always loses.

1. **Blocked / waiting on external** — if work is parked on a client or vendor
   reply, surface that first; do not start new work on top of a known blocker.
2. **Brief changed** — a scope change invalidates downstream artifacts; handle
   it before continuing, or you build on a stale brief.
3. **Done-check / verify** — any "about to claim delivered" path runs its
   verification before the claim leaves your mouth.
4. **Lifecycle order** — otherwise advance in spine order:
   BRIEF → SHOOT-PLAN → CAPTURE → CULL/EDIT → DELIVER.
5. **Advisory** — a pure "explain / should I" question answers without starting
   a phase.
6. **Default / no-match** — loses to everything; only fires when nothing else
   matches.

---

## Standard Branches (paste-in)

<!-- ===================================================================== -->
<!-- <<KEEP THE 3 MANDATORY; ADD OFFERED AS NEEDED>>                        -->
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
│   Gate: feedback resolved and selects re-verified (re-review the redline)
```

---

## Reasoning-mode legend

Not every node deserves the same depth of thought. Mark each leaf so the agent
spends judgment where taste matters and moves fast where it doesn't.

- **FULL (taste-heavy — slow down, reason hard):**
  - `culling` — choosing the keepers is the whole craft; a wrong cull can't be
    un-rung downstream.
  - `retouching` — skin, color, and mood are judgment calls, not presets.
  - `shoot-planning` — anticipating light and moments is where the photos are
    won or lost.
  - `advisory-answer` — advice carries weight; get it right or say you're unsure.

- **CAVE (mechanical — fast, low ceremony):**
  - `card-offload` — copy, verify checksum, back up to two locations. No taste.
  - `gallery-delivery` export/rename — batch export, file naming, upload. Rote.
  - `scratchpad-read` — recover state; pure lookup.

- **MED (structured, but not deep):**
  - `intake-triage`, `brief-confirm`, `plan-review`, `verify-delivery` — follow
    the checklist, confirm the artifact, move on.

---

## You are rationalizing if…

These are the lies a tired photographer (or a hurried agent) tells. Each one has
a one-line rebuttal. If you catch yourself saying the left side, do the right.

- *"I'll cull later, let me retouch the obvious keepers first."* → Cull BEFORE
  you retouch, always. Retouching un-culled frames burns hours on rejects.
- *"The couple basically approved the plan in the call."* → "Basically" is not
  the SHOOT-PLAN gate. Get the written confirmation in the scratchpad.
- *"One backup is fine, the card's right here."* → Two locations or the CAPTURE
  gate is not met. Cards fail; weddings don't repeat.
- *"I'll skip the done-check, I know it's all there."* → Knowing isn't the gate.
  Confirm the deliverable count and the client receipt before you say delivered.
- *"They added a second venue but the old timeline's close enough."* → A brief
  change re-enters SHOOT-PLAN. Close-enough timelines miss the new golden hour.
- *"They're just asking my opinion, I'll start editing to show them."* → That's
  an advisory question. Answer it; don't silently start a phase.

---

## Attribution

<!-- Required. Credit the people whose work you bundled. -->

Skills in `skills/` are by **<<YOUR NAME>>** (link to your GitHub or site).
The FLOW.md routing layer is by **<<YOUR NAME>>**, licensed under **<<LICENSE>>**
(e.g. CC-BY-SA-4.0).

If you bundled skills from another author, credit each here with the original
project link and its license. The routing layer and the skills can have
different authors — say so plainly.
