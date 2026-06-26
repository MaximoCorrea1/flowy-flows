---
name: matt-pocock-flow
description: Run engineering work end to end: triage, model the domain, design interfaces, build test-first, diagnose, and hand off.
version: 0.1.0
license: MIT
domain: software-engineering
---

# Engineering Discipline

A Flow that routes Matt Pocock's engineering skills across one coherent lifecycle: take a raw issue, sharpen the domain language, design a deep interface, build it test-first, diagnose what breaks, and hand the work off cleanly. Each skill fires at the step where it earns its keep, behind a gate that names a real artifact (a passing test, a recorded decision), so discipline holds even on a hurried day.

## What it routes to

- **triage** — move an issue or external PR through a small state machine, ending in an agent-ready brief.
- **domain-modeling** — challenge terms, stress-test with scenarios, and write the glossary and ADRs down as decisions land.
- **codebase-design** — shared vocabulary for deep modules: small interfaces, clean seams, testable through the interface.
- **tdd** — red-green-refactor in vertical slices, one test then one implementation, never all tests up front.
- **diagnosing-bugs** — build a tight red-capable feedback loop first, then reproduce, minimise, hypothesise, fix, and regression-test.
- **handoff** — compact the session into a document a fresh agent can pick up, referencing artifacts by path.

## How to use

Run `/flowy matt-pocock-flow`. The Flowy engine loads the FLOW.md router and keeps its routing active every turn, so the right skill is invoked at the right step. You do not paste anything into your project configuration; the engine handles activation.

## Attribution

Skills vendored from Matt Pocock's open-source repository (https://github.com/mattpocock/skills), MIT licensed. See ATTRIBUTION.md. Listed for attribution; Matt Pocock does not endorse Flowy.
