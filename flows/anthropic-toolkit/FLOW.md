# FLOW.md: Anthropic Toolkit

> Routes 13 official Anthropic skills to whatever you are building: pick the one skill that matches, build, verify.
> Skills by Anthropic (https://github.com/anthropics/skills, Apache 2.0). Routing by Flowy.

<!-- The Flowy engine supplies the universal contract (announce ritual, invoke/READ,
     host-wins, post-compaction re-read). This file carries only the routing. -->

## Routing

```
USER DESCRIBES WHAT THEY WANT TO BUILD
  ├─ building something visual? DISAMBIGUATE first:
  │    ├─ production web page / component (a deployed app)?  → invoke frontend-design
  │    ├─ self-contained claude.ai artifact / widget?       → invoke web-artifacts-builder
  │    └─ static visual file (poster, cert, infographic)?   → invoke canvas-design
  ├─ test a web app (E2E, visual, Playwright)?              → invoke webapp-testing
  ├─ Claude API / Anthropic SDK integration?               → invoke claude-api
  ├─ MCP server or MCP tools?                               → invoke mcp-builder
  ├─ apply Anthropic's brand palette/type to an artifact?   → invoke brand-guidelines
  ├─ apply a preset theme to a deck or document?            → invoke theme-factory
  ├─ generative / algorithmic art?                          → invoke algorithmic-art
  ├─ GIF for Slack / team chat?                             → invoke slack-gif-creator
  ├─ internal comms (announcement, memo, update)?           → invoke internal-comms
  ├─ collaborative document?                                → invoke doc-coauthoring
  └─ create a new skill?                                    → invoke skill-creator
```

## Priority on collision

1. **Disambiguate "visual" first**: web page (frontend-design) vs claude.ai artifact (web-artifacts-builder) vs static file (canvas-design). Most mis-routes happen here.
2. Otherwise the most specific match wins; if two fit, pick the one matching the deliverable's final form (where it runs, how it ships).

## Sequences

Some builds chain skills. Record each output before switching:
- "Build a landing page" → brand-guidelines (identity) → frontend-design (build) → webapp-testing (verify).
- "Build an MCP server" → mcp-builder → webapp-testing.
- "Claude-powered feature" → claude-api → frontend-design → webapp-testing.

## Out of scope

Backend APIs and servers, mobile apps, CLI tools, data pipelines, infra/DevOps, and creating a NEW brand from scratch. (brand-guidelines applies Anthropic's brand only; theme-factory themes decks and docs, it is not a design-token system.) For those, use the host agent's built-in capabilities.

## You are rationalizing if you think…

- "It's visual, so frontend-design." → First decide page vs claude.ai artifact vs static file; the wrong one wastes the build.
- "brand-guidelines will make my brand." → No. It applies Anthropic's brand. A new brand is out of scope.
- "theme-factory means design tokens." → No. It themes slide decks and documents only.
- "I'll skip the test step." → If you built a web app, webapp-testing verifies it before you claim done.

## Attribution

Skills in `skills/` by Anthropic, Apache 2.0 (https://github.com/anthropics/skills). FLOW.md routing by Flowy, CC-BY-SA-4.0.
