# FLOW.md — Your Flow Name Here

<!-- Replace "Your Flow Name Here" with your actual Flow name. -->

> A one-paragraph summary of what your Flow does and who it's for.
> Outcome-named, not feature-named. Example: "End-to-end cold-email pipeline:
> research a prospect, draft a personalized message, send through your provider,
> log the reply." Bad: "A Flow for marketing."

---

## How this works

Every skill in `skills/` is a standalone SKILL.md file the agent reads and follows.
This FLOW.md is the routing layer — it tells the agent WHEN to invoke each skill.

When the routing table below says "invoke [skill-name]":
→ The agent reads `skills/[skill-name]/SKILL.md` in this folder
→ Follows its instructions completely
→ Returns to this FLOW.md for the next decision

---

## Routing Logic

### Decision tree

<!-- This is the CORE of your Flow. Without a decision tree, your FLOW.md is prose,
     not a router. The validator will reject prose-only FLOW.md files.
     
     Replace the example below with YOUR routing decisions. Keep the tree shape. -->

```
USER MESSAGE RECEIVED
  │
  ├─ First message in a new session?
  │   → skills/your-skill-here/SKILL.md
  │   Gate: bootstrap context established
  │
  ├─ User describes a new task in your domain?
  │   → skills/your-skill-here/SKILL.md
  │   Gate: scope clarified before action
  │
  └─ User wants to verify the result?
      → skills/your-skill-here/SKILL.md
      Gate: evidence shown before claiming done
```

### Priority when multiple triggers match

<!-- Define which routes win when multiple could fire. Required. -->

1. **Verification** — completion claims take precedence
2. **Bootstrap** — first-message setup runs once
3. Everything else in natural order

### Before every turn

State your routing decision:
  `Routing: [skill-name] — [one-line reason]`
If no skill applies: `Routing: none — [reason]`

---

## Per-Skill Detail

### your-skill-here

<!-- Document each skill: when it fires, what it does, what the gate is. -->

**Fires when:** [describe the trigger conditions]

**What it does:** [one paragraph]

**Gate:** [the condition that must be met before this skill is considered complete]

**Skip when:** [conditions where this skill should NOT fire]

---

## Attribution

<!-- Required: tell users who made this Flow and where the skills came from. -->

Skills in `skills/` are by [Your Name] (link to your GitHub or website).
The FLOW.md routing document is by [Your Name], licensed under [your license].

If you bundled skills from another author, credit them here with the original
project link and license.
