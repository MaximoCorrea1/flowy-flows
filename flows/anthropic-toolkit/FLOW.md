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

Paste into your project's CLAUDE.md:

```markdown
## Skill routing (Anthropic Toolkit)

Read at session start: [path-to-this-flow]/FLOW.md

When the user's task matches a trigger below, read and follow the
corresponding skill. State your routing decision each turn.

| Trigger | Read + follow |
|---------|---------------|
| Building a web UI, page, or component | skills/frontend-design/SKILL.md |
| Testing a web app (Playwright, E2E, visual) | skills/webapp-testing/SKILL.md |
| Building a self-contained web artifact (demo, widget, tool) | skills/web-artifacts-builder/SKILL.md |
| Using the Claude API or Anthropic SDK | skills/claude-api/SKILL.md |
| Building an MCP server or tools | skills/mcp-builder/SKILL.md |
| Creating brand identity (colors, type, logo, voice) | skills/brand-guidelines/SKILL.md |
| Drawing with HTML5 Canvas | skills/canvas-design/SKILL.md |
| Generating a design system theme | skills/theme-factory/SKILL.md |
| Creating generative/algorithmic art | skills/algorithmic-art/SKILL.md |
| Making animated GIFs for Slack/chat | skills/slack-gif-creator/SKILL.md |
| Drafting internal company communications | skills/internal-comms/SKILL.md |
| Collaborative document writing | skills/doc-coauthoring/SKILL.md |
| Creating a new Claude Code skill | skills/skill-creator/SKILL.md |

Routing: [skill-name] — [reason]
```

---

## Routing Logic

```
USER DESCRIBES WHAT THEY WANT TO BUILD
  │
  ├─ Web UI / page / component / layout?
  │   → skills/frontend-design/SKILL.md
  │
  ├─ Test a web app (E2E, visual, Playwright)?
  │   → skills/webapp-testing/SKILL.md
  │
  ├─ Self-contained artifact (demo, widget, codepen-style)?
  │   → skills/web-artifacts-builder/SKILL.md
  │
  ├─ Claude API / Anthropic SDK integration?
  │   → skills/claude-api/SKILL.md
  │   (includes refs for Python, TS, Ruby, Go, Java, PHP, C#, curl)
  │
  ├─ MCP server / MCP tools?
  │   → skills/mcp-builder/SKILL.md
  │
  ├─ Brand identity / style guide / logo?
  │   → skills/brand-guidelines/SKILL.md
  │
  ├─ Design system theme / tokens?
  │   → skills/theme-factory/SKILL.md
  │
  ├─ Canvas drawing / visualization?
  │   → skills/canvas-design/SKILL.md
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

---

## Attribution

Skills from [anthropics/skills](https://github.com/anthropics/skills)
by Anthropic, Apache License 2.0.
FLOW.md routing by [Flowy](https://flowy.dev).
