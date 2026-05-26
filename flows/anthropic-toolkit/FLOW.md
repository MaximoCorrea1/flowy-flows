# FLOW.md — Anthropic Toolkit

> 13 official Anthropic skills with a routing layer. The agent reads
> the right skill based on what you're building.
>
> Skills by Anthropic (https://github.com/anthropics/skills, Apache 2.0).
> FLOW.md routing by Flowy.

## How this works

When the routing table says "invoke [skill-name]":
→ Read `skills/[skill-name]/SKILL.md` in this directory
→ Follow its instructions
→ Return to FLOW.md for the next routing decision

---

## CLAUDE.md Integration

Add one line to your project's CLAUDE.md:

```
Read [path-to-this-flow]/FLOW.md at session start.
```

Replace `[path-to-this-flow]` with the actual path. All skill paths in
this file are relative to FLOW.md's own directory.

---

## Routing Logic

```
USER DESCRIBES WHAT THEY WANT TO BUILD
  │
  ├─ Building something visual? → DISAMBIGUATE:
  │   a) Production web page/component (HTML/CSS/JS, deployed app)?
  │      → skills/frontend-design/SKILL.md
  │   b) Self-contained claude.ai artifact / demo / widget (bundled, no server)?
  │      → skills/web-artifacts-builder/SKILL.md
  │   c) Static visual file — poster, certificate, infographic (PNG/PDF)?
  │      → skills/canvas-design/SKILL.md
  │
  ├─ Test a web app (E2E, visual, Playwright)?
  │   → skills/webapp-testing/SKILL.md
  │
  ├─ Claude API / Anthropic SDK integration?
  │   → skills/claude-api/SKILL.md
  │   (includes refs for Python, TS, Ruby, Go, Java, PHP, C#, curl)
  │
  ├─ MCP server / MCP tools?
  │   → skills/mcp-builder/SKILL.md
  │
  ├─ Apply Anthropic's brand palette/typography to an existing artifact?
  │   → skills/brand-guidelines/SKILL.md
  │   (⚠ Applies Anthropic's specific colors + fonts, NOT for creating a new brand)
  │
  ├─ Apply a preset theme to a slide deck or document?
  │   → skills/theme-factory/SKILL.md
  │   (⚠ 10 built-in slide/doc themes, NOT for CSS tokens or design system codegen)
  │
  ├─ Generative art / algorithmic visuals?
  │   → skills/algorithmic-art/SKILL.md
  │
  ├─ GIF for Slack / team chat?
  │   → skills/slack-gif-creator/SKILL.md
  │
  ├─ Internal comms (announcement, memo, update)?
  │   → skills/internal-comms/SKILL.md
  │
  ├─ Collaborative document?
  │   → skills/doc-coauthoring/SKILL.md
  │
  └─ Create a new skill?
      → skills/skill-creator/SKILL.md
```

### Combining skills

Some tasks benefit from multiple skills in sequence:

- **"Build a landing page"** → brand-guidelines (identity) → frontend-design (build) → webapp-testing (verify)
- **"Build an MCP server for my app"** → mcp-builder (server) → webapp-testing (test)
- **"Create a Claude-powered feature"** → claude-api (integration) → frontend-design (UI) → webapp-testing (test)

The agent reads each skill in sequence. Each skill's output feeds the next.

**Cross-skill handoff** — before switching to the next skill in a
sequence, record a brief scratchpad note:
- Output files from the previous skill
- Server command + port (if applicable)
- Key variables the next skill needs

This prevents the next skill from starting blind.

---

## Out of scope

This toolkit does NOT cover:
- Backend APIs, REST/GraphQL servers
- Mobile apps (iOS, Android, React Native)
- CLI tools, shell scripts, data pipelines
- Infrastructure, DevOps, Kubernetes
- Creating a brand identity from scratch (brand-guidelines applies Anthropic's brand only)
- CSS design tokens / design system codegen (theme-factory themes slide decks only)

For these, use Claude Code's built-in capabilities directly.

---

## Attribution

Skills from [anthropics/skills](https://github.com/anthropics/skills)
by Anthropic, Apache License 2.0.
FLOW.md routing by [Flowy](https://flowy.dev).
