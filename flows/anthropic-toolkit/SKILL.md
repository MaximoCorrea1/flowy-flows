---
name: anthropic-toolkit
description: 13 official Anthropic skills bundled with a FLOW.md router — frontend design, webapp testing, Claude API, MCP builder, brand guidelines, and more.
version: 0.1.0
license: Apache-2.0
---

# Anthropic Toolkit

All 13 open-source skills from [Anthropic's official skills repo](https://github.com/anthropics/skills),
bundled with a FLOW.md router that helps your agent pick the right skill
for the job.

## Attribution

The skills in `skills/` are **not my creation**. They are the work of
**Anthropic** and contributors, from the
[anthropics/skills](https://github.com/anthropics/skills) repository,
licensed under the **Apache License 2.0** (see LICENSE.txt).

The proprietary document skills (docx, pdf, pptx, xlsx) are NOT included
in this bundle — only the Apache 2.0 licensed skills.

What Flowy added: the `FLOW.md` routing document.

## The 13 skills

| Category | Skill | What it does |
|----------|-------|-------------|
| **Web Dev** | frontend-design | Build distinctive, production-grade frontend interfaces |
| **Web Dev** | webapp-testing | Test web applications with Playwright |
| **Web Dev** | web-artifacts-builder | Create self-contained web artifacts |
| **API** | claude-api | Build apps with the Claude API (8 language refs) |
| **API** | mcp-builder | Build MCP servers and tools |
| **Design** | brand-guidelines | Create brand identity systems |
| **Design** | canvas-design | Design with HTML5 Canvas |
| **Design** | theme-factory | Generate design system themes |
| **Creative** | algorithmic-art | Generate algorithmic/generative art |
| **Creative** | slack-gif-creator | Create animated GIFs for Slack |
| **Writing** | internal-comms | Draft internal company communications |
| **Writing** | doc-coauthoring | Collaborative document writing |
| **Meta** | skill-creator | Create new Claude Code skills |

## How to use

1. Copy this Flow folder into your project
2. Add the CLAUDE.md integration block from FLOW.md
3. Describe what you want to build — the agent routes to the right skill
