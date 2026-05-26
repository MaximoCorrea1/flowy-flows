---
name: solo-launch-playbook
description: 7-module marketing pipeline for solo founders — CRO audit, SEO research, content scoring, X threads, social content, outbound, growth experiments. From landing page to launch day to post-launch measurement.
version: 0.1.0
license: MIT
---

# Solo Launch Playbook

Seven marketing modules wired into a launch pipeline. Takes a solo
founder from "I have a product" to "I launched, measured, and know
what's working."

## Attribution

The modules in `modules/` are **not my creation**. They are the work
of **Eric Siu / Single Grain** and contributors, from the
[ai-marketing-skills](https://github.com/ericosiu/ai-marketing-skills)
repository, licensed under the **MIT License** (see LICENSE).

What Flowy added: the FLOW.md routing that wires these modules into
a coherent launch pipeline with phased execution.

## The 7 modules

| Phase | Module | What it does |
|-------|--------|-------------|
| **Audit** | conversion-ops | CRO audit of your landing page + survey lead magnet generator |
| **Research** | seo-ops | Keyword intelligence, GSC analysis, competitor gaps, trend detection |
| **Research** | content-ops | Content quality scoring with expert panels + production pipeline |
| **Create** | x-longform-post | Write viral X/Twitter threads in founder voice with ASCII diagrams |
| **Create** | short-form-pipeline | Social content production pipeline (clips, carousels, quotes) |
| **Distribute** | outbound-engine | Cold outreach sequences with ICP templates + copy rules |
| **Measure** | growth-engine | Experiment framework with statistical testing + weekly scorecard |

## Prerequisites

Some modules include Python scripts that need:
- Python 3.x
- `pip install -r requirements.txt` per module
- Optional API keys: `AHREFS_TOKEN` (seo-ops), Google Search Console
  auth (seo-ops), `OPENAI_API_KEY` (content-ops scoring)

The SKILL.md files work WITHOUT the Python scripts — the scripts add
automation but the agent can follow the skill instructions manually.

## How to use

1. Copy this Flow folder into your project
2. Add one line to your CLAUDE.md: `Read [path]/FLOW.md at session start.`
3. Tell the agent: "I'm launching [product]. Help me run the playbook."
