---
name: anthropic-toolkit
description: 13 official Anthropic skills bundled with a FLOW.md router — frontend design, webapp testing, Claude API, MCP builder, brand guidelines, and more.
version: 0.2.0
license: Apache-2.0
upstream: https://github.com/anthropics/skills
attribution: Skills by Anthropic
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
| **Design** | brand-guidelines | Apply Anthropic's brand (coral palette, Poppins/Lora) to artifacts — NOT for creating new brands |
| **Design** | canvas-design | Design with HTML5 Canvas |
| **Design** | theme-factory | Apply preset slide deck/document themes (10 built-in) — NOT for CSS design tokens |
| **Creative** | algorithmic-art | Generate algorithmic/generative art |
| **Creative** | slack-gif-creator | Create animated GIFs for Slack |
| **Writing** | internal-comms | Draft internal company communications |
| **Writing** | doc-coauthoring | Collaborative document writing |
| **Meta** | skill-creator | Create new Claude Code skills |

## How to use

Run `/flowy:anthropic-toolkit` to activate, then describe what you want to build. The Flowy hook enforces FLOW.md routing for the rest of the session, with no manual setup. (`/flowy:anthropic-toolkit status` to verify; `/flowy:anthropic-toolkit deactivate` to turn off.)
