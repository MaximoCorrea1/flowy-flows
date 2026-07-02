# FLOW.md: Solo Launch Playbook

> 7 marketing modules wired into a 5-phase launch pipeline for a solo founder on a $0 budget. Organic-first. Run the phases in order; each feeds the next.
> Modules by Eric Siu / Single Grain (https://github.com/ericosiu/ai-marketing-skills, MIT). Routing by Flowy.

<!-- Pipeline flow. The engine supplies the universal contract; this file carries the
     phase spine + module routing. Record each phase's output before the next. -->

## Phases

Run in order. Each phase exits on a named artifact; the next phase reads it.

1. **Audit**: invoke conversion-ops. Gate: a CRO report naming the top 3 conversion blockers (plus a survey lead magnet).
2. **Research**: invoke seo-ops, then content-ops. Gate: keyword targets chosen and a content-quality baseline set.
3. **Create**: invoke x-longform-post, then short-form-pipeline. Gate: a launch thread plus 5-7 social posts ready.
4. **Distribute**: invoke outbound-engine. Gate: outreach sequences ready and the first batch sent.
5. **Measure**: invoke growth-engine. Gate: the first weekly scorecard produced.

After launch, cycle phases 2-5 weekly.

## Routing (trigger to module)

**The rule:** when a trigger matches, INVOKE the named module BEFORE doing the task yourself. Doing the work without first invoking is the failure this Flow exists to stop.

```
USER MESSAGE
  ├─ "audit my landing page" / "why aren't people converting?"   → invoke conversion-ops       (Phase 1)
  ├─ "find keywords" / "SEO analysis" / "competitor gaps"        → invoke seo-ops              (Phase 2)
  ├─ "score my content" / "what should I write?"                 → invoke content-ops          (Phase 2)
  ├─ "write a launch thread" / "X post" / "Show HN draft"        → invoke x-longform-post      (Phase 3)
  ├─ "create social content" / "clips" / "carousels"             → invoke short-form-pipeline  (Phase 3)
  ├─ "cold outreach" / "find users" / "email sequence"           → invoke outbound-engine      (Phase 4)
  └─ "track experiments" / "what's working?" / "scorecard"       → invoke growth-engine        (Phase 5)
```

## Priority on collision

1. Earlier phase first: do not start Phase N+1 while Phase N's gate is unmet. Each phase's output is the next phase's input.
2. A scope change (new audience, new product) re-enters Phase 1 (Audit).

## Solo-founder constraints (apply to every module)

These modules were built for funded growth teams. For a solo founder at $0:

- **No paid ads.** Replace ad steps with organic distribution (Show HN, X threads, subreddit posts, community engagement).
- **No team.** You are the team; the agent does the work. Ignore "hand to the content team" steps.
- **Free tools only.** Substitute free alternatives for HubSpot / Salesforce / paid analytics (a spreadsheet CRM, free web analytics, Search Console).
- **Ship over polish.** Aim for 7/10 on launch content; 10/10 is later.
- **One channel at a time.** Finish a phase before the next; the pipeline is sequential on purpose.

## You are rationalizing if you think…

- "Skip the audit, just launch." → Phase 1 first. Launching a leaky page wastes the traffic you fought for.
- "Run all the modules at once." → Phases are sequential; each needs the prior one's output.
- "This needs a budget." → No. Every paid step has an organic substitute (see constraints).
- "I know which phase I'm in after compaction." → After compaction, re-read this file and restate which phase you are in before continuing.

## Attribution

Modules in `modules/` by Eric Siu / Single Grain, MIT (https://github.com/ericosiu/ai-marketing-skills). FLOW.md routing by Flowy, CC-BY-SA-4.0.
