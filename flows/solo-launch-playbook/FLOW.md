# FLOW.md — Solo Launch Playbook

> 7 marketing modules wired as a phased launch pipeline for solo founders.
> $0 budget assumed. Organic-first, community-driven.
>
> Modules by Eric Siu / Single Grain (MIT, https://github.com/ericosiu/ai-marketing-skills).
> FLOW.md routing by Flowy.

---

## How this works

Each module in `modules/` is a SKILL.md with marketing instructions +
optional Python scripts. This FLOW.md routes between them in a 5-phase
launch pipeline.

When the routing says "invoke [module]":
→ Read `modules/[module]/SKILL.md` in this directory
→ Follow its instructions
→ Record output artifacts (copy, briefs, data) before moving to next phase

---

## CLAUDE.md Integration

Add one line to your project's CLAUDE.md:

```
Read [path-to-this-flow]/FLOW.md at session start.
```

---

## The Launch Pipeline

Run phases in order. Each phase builds on the previous one's output.

```
PHASE 1: AUDIT (before anything else)
  │
  │  "Is my landing page converting? What's broken?"
  │  → modules/conversion-ops/SKILL.md
  │  Output: CRO audit report, prioritized fix list, survey lead magnet
  │  Gate: top 3 conversion blockers identified
  │
  ▼
PHASE 2: RESEARCH (know your battlefield)
  │
  │  "What keywords should I target? What content gaps exist?"
  │  → modules/seo-ops/SKILL.md
  │  Output: keyword targets, content attack brief, competitor gaps
  │
  │  "How good is my existing content? What scores well?"
  │  → modules/content-ops/SKILL.md
  │  Output: content scores, production pipeline, quality rubric
  │  Gate: keyword targets + content quality baseline established
  │
  ▼
PHASE 3: CREATE (build the launch content)
  │
  │  "Write the Show HN / X launch thread"
  │  → modules/x-longform-post/SKILL.md
  │  Output: launch thread draft with hooks, ASCII diagrams, payoff
  │
  │  "Create social content for the launch week"
  │  → modules/short-form-pipeline/SKILL.md
  │  Output: social clips, quotes, carousels, scheduled posts
  │  Gate: launch thread + 5-7 social posts ready
  │
  ▼
PHASE 4: DISTRIBUTE (reach people)
  │
  │  "Find and reach potential users/creators"
  │  → modules/outbound-engine/SKILL.md
  │  Output: ICP profiles, cold email sequences, outreach list
  │  Gate: outreach sequences ready + first batch sent
  │
  ▼
PHASE 5: MEASURE (what worked?)
  │
  │  "Set up experiments and track results"
  │  → modules/growth-engine/SKILL.md
  │  Output: experiment definitions, data logs, statistical scores,
  │          weekly scorecard, living playbook of what works
  │  Gate: first weekly scorecard produced
  │
  ▼
REPEAT: Phases 2-5 cycle weekly post-launch
```

---

## Routing Table (quick reference)

| Trigger | Module | Phase |
|---------|--------|-------|
| "Audit my landing page" / "Why aren't people converting?" | modules/conversion-ops/SKILL.md | 1 |
| "Find keywords" / "SEO analysis" / "Competitor gaps" | modules/seo-ops/SKILL.md | 2 |
| "Score my content" / "Content pipeline" / "What should I write?" | modules/content-ops/SKILL.md | 2 |
| "Write a launch thread" / "X post" / "Show HN draft" | modules/x-longform-post/SKILL.md | 3 |
| "Create social content" / "Clips" / "Social posts" | modules/short-form-pipeline/SKILL.md | 3 |
| "Cold outreach" / "Find users" / "Email sequence" | modules/outbound-engine/SKILL.md | 4 |
| "Track experiments" / "What's working?" / "Weekly scorecard" | modules/growth-engine/SKILL.md | 5 |

---

## Solo Founder Constraints (applied to ALL modules)

These modules were built for growth teams at funded startups. For a
solo founder with $0 budget, apply these constraints:

1. **No paid ads.** Skip any step that assumes ad spend. Replace with
   organic distribution (Show HN, X threads, subreddit cross-posts,
   community engagement).

2. **No team.** Skip any step that assigns work to "the content team"
   or "the growth team." You ARE the team. The agent does the work.

3. **No enterprise tools.** If a module references HubSpot, Salesforce,
   or paid analytics — substitute free alternatives (Supabase for CRM,
   Plausible/Vercel Analytics for tracking, Google Search Console for
   SEO data).

4. **Ship > perfect.** The modules have quality scoring rubrics. For V1
   launch, aim for 7/10 quality on all content. 10/10 polish is V2.

5. **One channel at a time.** Don't run all 7 modules simultaneously.
   Follow the phases in order. Finish Phase 1 before starting Phase 2.
   The pipeline is sequential for a reason — each phase's output feeds
   the next.

---

## Running this for Flowy specifically

If you're using this playbook for Flowy's own launch:

**Phase 1 (Audit):**
- Audit flowy.dev landing page for conversion
- Check: does the hero copy land? Does "AI Flows that just work :)"
  communicate value in <3 seconds?

**Phase 2 (Research):**
- SEO targets: "AI agent skills," "AI workflow," "Claude Code skills,"
  "AI coding discipline," "flow-based AI development"
- Content baseline: the 3 seed Flows in the catalog ARE the content

**Phase 3 (Create):**
- Show HN thread: draft at docs/comms/2026-06-08-show-hn-post.md
- X thread: mirror the Show HN narrative for Twitter/X
- Social: 5 posts highlighting one seed Flow each + the FLOW.md concept

**Phase 4 (Distribute):**
- Outreach: contact 10-20 AI skill creators (superpowers contributors,
  gstack users, CE plugin authors) and invite them to publish on Flowy
- Community: post in r/ClaudeAI, r/SaaS, r/indiehackers

**Phase 5 (Measure):**
- Experiments: track Show HN comments, signups, GitHub stars, Flow
  downloads per week
- Weekly scorecard: Monday morning, review what worked

---

## Cross-skill handoff

Before switching to the next phase's module, record:
- **Output artifacts** from the current phase (files, URLs, data)
- **Key numbers** (scores, keyword targets, outreach list size)
- **Decisions made** (which keywords to target, which CRO fixes to ship)

This scratchpad feeds the next module's context.

---

## Attribution

Modules from [ai-marketing-skills](https://github.com/ericosiu/ai-marketing-skills)
by Eric Siu / Single Grain, MIT License.
FLOW.md routing by [Flowy](https://flowy.dev).
