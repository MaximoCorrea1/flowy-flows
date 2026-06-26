---
name: addy-sdlc-flow
description: Ship software end to end. Routes spec, test-first, hardening, debugging, CI, and launch skills to the right step.
version: 0.1.0
license: MIT
domain: software-engineering
---

# Full SDLC

Six battle-tested engineering skills from Addy Osmani's agent-skills, wired into one lifecycle. You describe the work; Flowy fires the right skill at the right step, from a written spec through a tested, hardened, shipped change.

## What it covers

- **Spec** before code, so you build the right thing.
- **Test-first** implementation, so "seems right" is never the bar.
- **Hardening** against the OWASP and STRIDE risks every untrusted input creates.
- **Systematic debugging** when something breaks, root cause before fix.
- **CI gates** so nothing reaches main without passing tests, lint, types, and build.
- **Launch** with monitoring and a rollback plan, every deploy reversible.

## How to use

Install the Flow, then run `/flowy:addy-sdlc-flow`. From then on Flowy reads `FLOW.md` and announces which skill fires for each step you describe. You do not paste anything into your own instructions; the engine makes the routing mandatory and keeps it active across long sessions.

## Attribution

The six skills are vendored from Addy Osmani's agent-skills (MIT). See `ATTRIBUTION.md` and `LICENSE`. The routing layer is by Flowy. Listed for attribution; Addy Osmani does not endorse Flowy.
