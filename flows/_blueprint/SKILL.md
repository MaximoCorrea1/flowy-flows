---
name: _blueprint
description: Format-canonical starter Flow with a deep, domain-agnostic decision tree (phases + gates + standard branches). Fork it, fill the L1-L4 ladder for your domain, validate, submit.
version: 0.2.0
license: CC-BY-SA-4.0
domain: photography
---

# Blueprint — Starter Flow

This is the format-canonical starter Flow for Flowy contributors. It demonstrates
every required field and section a published Flow needs.

## How to use this

1. Copy this entire folder somewhere OUTSIDE the flowy-flows repo (so the activator's project-local override warnings don't trip)
2. Rename the folder from `_blueprint` to your Flow's name (lowercase-with-hyphens)
3. Rename the `skills/your-skill-here/` folder to your actual skill name
4. Edit FLOW.md — replace the example routing with YOUR decision tree
5. Edit each skills/<name>/SKILL.md with your actual skill content
6. Validate at https://flowy.dev/create-a-flow/validate
7. Submit at https://flowy.dev/me/flows/new OR open a PR to flowy-flows

## What's required

- `FLOW.md` — routing decision tree (NOT prose)
- `SKILL.md` (this file) — frontmatter + overview
- `LICENSE` — your license file
- `skills/` directory with at least one skill
- 10 files maximum in total

## What gets rejected

- FLOW.md that's prose without a decision tree
- Skills referenced but not bundled in skills/
- No LICENSE file
- A Flow that's a thin re-skin of an existing skill with no routing value
