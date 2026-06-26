# FLOW.md: Design & Test

> Build front-end work that looks deliberate and is proven to run, by routing the design, test, and skill-authoring steps to the right skill and refusing to call UI "done" until it has been driven against a running app.

> Skills vendored from Anthropic (Apache-2.0). See ATTRIBUTION.md. Routing by Flowy.

<!-- The Flowy engine supplies the universal contract (announce ritual, invoke/READ,
     host-wins, post-compaction re-read). This file carries only the routing. -->

## Phases

1. **Design**. Entry: a UI is being built or reshaped and no intentional design exists yet. Gate: a design plan (palette, type, layout, signature) committed before any production code.
2. **Build**. Entry: the design plan is approved and code is being written. Gate: the interface implemented from that plan, reachable in a running app.
3. **Verify**. Entry: any claim that the UI renders, works, or is done. Gate: a Playwright run against the running app plus a screenshot that proves the claim.
4. **Capture**. Entry: this design-then-verify loop is one you keep repeating and want to reuse. Gate: a packaged skill whose evals were run.

## Routing

```
USER MESSAGE / NEW REQUEST (intake: classify the intent first)
  │
  ├─ Just asking a question, no UI to change (advisory / answer-only)?
  │   └─ answer directly, propose the matching phase  → no skill
  │      Gate: no artifact; routing recorded
  │
  ├─ Phase 1: needs an interface designed or reshaped?
  │   ├─ greenfield page / component, no visual direction yet?
  │   │   → invoke frontend-design
  │   │     Gate: design plan (palette, type, layout, signature) committed
  │   └─ restyling an existing screen that reads templated?
  │       → invoke frontend-design
  │         Gate: revised plan naming what changed and why
  │
  ├─ Phase 2: design approved, writing the UI code?
  │   └─ implement strictly from the committed plan
  │       → invoke frontend-design
  │         Gate: interface reachable in a running app
  │
  ├─ Phase 3, DONE-CHECK: about to claim it renders / works / is done?
  │   ├─ server already running?
  │   │   → invoke webapp-testing
  │   │     Gate: Playwright run + screenshot proving the claim
  │   └─ server not started yet?
  │       → invoke webapp-testing
  │         Gate: with_server.py launches it, then a passing Playwright run
  │
  ├─ Phase 4: repeating this loop and want it reusable?
  │   └─ capture the workflow as a skill
  │       → invoke skill-creator
  │         Gate: packaged skill with evals run
  │
  ├─ SCOPE CHANGE: brief or requirements changed mid-flow?
  │   └─ re-enter the earliest affected phase  → invoke frontend-design
  │      Gate: design plan updated to the new brief before building resumes
  │
  ├─ BLOCKED: waiting on a design decision, asset, or credential?
  │   └─ park the task, name the resume trigger  → no skill
  │      Gate: blocker + resume condition written down
  │
  ├─ REVIEW-LOOP: design or test feedback came back?
  │   └─ address each item, then re-verify  → invoke webapp-testing
  │      Gate: every finding resolved and a fresh Playwright run is green
  │
  └─ DEFAULT: no branch fits?
      └─ state Routing: none and ask one narrowing question  → no skill
         Gate: intent restated so a phase can be picked
```

## Priority on collision

1. **Blocked**: a parked dependency wins; do not route work that cannot proceed.
2. **Scope changed**: a new brief re-enters the earliest affected phase before anything else.
3. **Done-check**: any pending "it works" claim routes to webapp-testing before moving on.
4. **Lifecycle order**: otherwise design before build before verify before capture.
5. **Advisory**: a pure question is answered without forcing a phase.
6. **Default**: nothing fits, so restate intent and ask one question.

## You are rationalizing if you think…

- "It looks right in the code, ship it." → invoke webapp-testing. Looking right in source is not running right in a browser; drive the actual app.
- "A big number, a gradient accent, and three feature cards is a clean hero." → invoke frontend-design. That is the templated default; the plan must justify a choice made for THIS brief.
- "The server is a hassle to start, I will eyeball the markup." → invoke webapp-testing. with_server.py starts it for you; an unrun page is an unverified page.
- "This is a tiny tweak, no design plan needed." → invoke frontend-design. Even a restyle commits a short plan naming what changed, so the change is deliberate not random.
- "I already verified earlier this session." → each done-claim is a fresh invocation; re-run webapp-testing against the current build before you say done.


## Additional skills (also available)

The full upstream set is vendored in this Flow. The routing above sequences
the core lifecycle; these additional skills are available and fire when their
trigger matches. See ATTRIBUTION.md for the complete list and license.

### general

- `algorithmic-art`: Creating algorithmic art using p5.js with seeded randomness and interactive parameter exploration. Use this when users request creating art using code, generative art, algorithmic art, flow fields, or particle systems. Create original algorithmic art rather than copying existing artists' work to avoid copyright violations.
- `brand-guidelines`: Applies Anthropic's official brand colors and typography to any sort of artifact that may benefit from having Anthropic's look-and-feel. Use it when brand colors or style guidelines, visual formatting, or company design standards apply.
- `canvas-design`: Create beautiful visual art in .png and .pdf documents using design philosophy. You should use this skill when the user asks to create a poster, piece of art, design, or other static piece. Create original visual designs, never copying existing artists' work to avoid copyright violations.
- `claude-api`: |-
- `doc-coauthoring`: Guide users through a structured workflow for co-authoring documentation. Use when user wants to write documentation, proposals, technical specs, decision docs, or similar structured content. This workflow helps users efficiently transfer context, refine content through iteration, and verify the doc works for readers. Trigger when user mentions writing docs, creating proposals, drafting specs, or similar documentation tasks.
- `internal-comms`: A set of resources to help me write all kinds of internal communications, using the formats that my company likes to use. Claude should use this skill whenever asked to write some sort of internal communications (status reports, leadership updates, 3P updates, company newsletters, FAQs, incident reports, project updates, etc.).
- `mcp-builder`: Guide for creating high-quality MCP (Model Context Protocol) servers that enable LLMs to interact with external services through well-designed tools. Use when building MCP servers to integrate external APIs or services, whether in Python (FastMCP) or Node/TypeScript (MCP SDK).
- `slack-gif-creator`: Knowledge and utilities for creating animated GIFs optimized for Slack. Provides constraints, validation tools, and animation concepts. Use when users request animated GIFs for Slack like "make me a GIF of X doing Y for Slack.
- `theme-factory`: Toolkit for styling artifacts with a theme. These artifacts can be slides, docs, reportings, HTML landing pages, etc. There are 10 pre-set themes with colors/fonts that you can apply to any artifact that has been creating, or can generate a new theme on-the-fly.
- `web-artifacts-builder`: Suite of tools for creating elaborate, multi-component claude.ai HTML artifacts using modern frontend web technologies (React, Tailwind CSS, shadcn/ui). Use for complex artifacts requiring state management, routing, or shadcn/ui components - not for simple single-file HTML/JSX artifacts.

## Attribution

- `frontend-design` by **Anthropic** (https://github.com/anthropics/skills), Apache-2.0.
- `webapp-testing` by **Anthropic** (https://github.com/anthropics/skills), Apache-2.0.
- `skill-creator` by **Anthropic** (https://github.com/anthropics/skills), Apache-2.0.

FLOW.md routing by Flowy. Listed for attribution; Anthropic does not endorse Flowy.
