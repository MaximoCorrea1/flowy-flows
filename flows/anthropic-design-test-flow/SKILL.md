---
name: anthropic-design-test-flow
description: Ship polished UI that is actually tested: design with intent, verify against a running app, capture the workflow.
version: 0.1.0
license: Apache-2.0
domain: software-engineering
---

# Design & Test

A Flow for building front-end work that looks deliberate and is proven to work, not just assumed to. It routes three Anthropic skills across one lifecycle: design the interface with a real point of view, then verify it against a running browser before any "done", and (optionally) package a workflow you keep repeating into a reusable skill.

## What it routes

- `frontend-design` (Anthropic, Apache-2.0): make distinctive, intentional UI choices that do not read as templated AI defaults.
- `webapp-testing` (Anthropic, Apache-2.0): drive the running app with Playwright to confirm it renders and behaves, capturing screenshots and console logs.
- `skill-creator` (Anthropic, Apache-2.0): turn a workflow you repeat into a tested, reusable skill.

The routing layer (FLOW.md) decides which one fires for the intent in front of you, and which named artifact has to exist before the work advances. The hard rule it enforces: a UI is not "working" until it has been driven against a running app.

## How to use

Install the Flowy plugin and run `/flowy:anthropic-design-test-flow`. The engine loads FLOW.md and keeps its routing active every turn, surviving compaction. You do not paste anything into your own CLAUDE.md.

## Attribution

Skills under `skills/` are by Anthropic (https://github.com/anthropics/skills), licensed Apache-2.0. See `ATTRIBUTION.md` and `LICENSE`. The FLOW.md routing is by Flowy. Listed for attribution; Anthropic does not endorse Flowy.
