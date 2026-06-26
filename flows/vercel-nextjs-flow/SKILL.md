---
name: vercel-nextjs-flow
description: Ship correct, fast, accessible Next.js UI. Routes Vercel's skills from build to a11y review to optimize to deploy.
version: 0.1.0
license: MIT
domain: frontend
---

# Next.js Production Quality

A Flow that takes a Next.js UI task from first keystroke to a live, fast,
accessible deployment. It curates five skills vendored from Vercel and a FLOW.md
router that fires the right one at the right phase, so the work follows a
lifecycle instead of a single trick.

## What it does

- **Build to guidelines.** Writes React and Next.js code against Vercel's
  performance rules and composition patterns (no render waterfalls, lean
  bundles, compound components over boolean-prop sprawl).
- **Review design and accessibility.** Audits the UI against the Web Interface
  Guidelines before it ships.
- **Optimize.** Runs an observability-first pass for Core Web Vitals, caching,
  and Vercel cost before declaring done.
- **Deploy.** Ships to Vercel (preview by default, production on request) and
  returns the live URL.

## Curated skills

- `react-best-practices` by Vercel: React and Next.js performance rules.
- `composition-patterns` by Vercel: scalable React component composition.
- `web-design-guidelines` by Vercel: Web Interface Guidelines review.
- `vercel-optimize` by Vercel: metric-backed cost and performance audit.
- `deploy-to-vercel` by Vercel: deploy and return the link.

See `ATTRIBUTION.md` for source and license (all MIT, from
https://github.com/vercel-labs/agent-skills). Listed for attribution; Vercel
does not endorse Flowy.

## How to use

Install the Flowy plugin and run `/flowy vercel-nextjs-flow`. The router then
fires the right skill per intent and holds each phase to its gate. The full
routing logic lives in `FLOW.md`.
