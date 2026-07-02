# Scaling: V1 → Post-V1 → Thousands of Flows

This doc explains how Flowy distribution scales from the V1 single-plugin model to a future where any creator can ship their own plugin.

## V1 (today): One bundled plugin

```
flowy-flows repo
├── .claude-plugin/         ← makes the repo a Claude Code plugin
├── skills/                 ← one wrapper SKILL.md per Flow
└── flows/                  ← Flow bundles (FLOW.md + skills/)
```

**Install:**
```
/plugin marketplace add MaximoCorrea1/flowy-flows
/plugin install flowy@flowy-flows
```

**Use:**
```
flowy:superpowers-flow
flowy:coding-wisdom
flowy:solo-launch-playbook
flowy:anthropic-toolkit
```

All 4 seed Flows ship together. Quality gate is the PR review in this repo. Works perfectly at 4-50 Flows.

## Post-V1: Per-creator plugin repos

When a Flow grows beyond hand-picked seed status — popular community Flows, creator-owned Flows, premium Flows — each lives in its own plugin repo:

```
github.com/CreatorX/cold-email-flow
├── .claude-plugin/
└── flow/                   ← single Flow bundle
    ├── FLOW.md
    └── skills/

github.com/CreatorY/rails-migration-flow
├── .claude-plugin/
└── flow/
```

**Install:**
```
/plugin marketplace add CreatorX/cold-email-flow
/plugin install cold-email-flow@CreatorX
```

**Use:**
```
cold-email-flow:activate
```

Each creator owns their own plugin. flowy.sh catalogs them all and shows the install command per Flow.

## Scale (thousands of Flows)

The mechanism doesn't change. What changes:

- **flowy.sh is the discovery surface** — browse, search, filter by category/creator/rating
- **Each listing page shows the install command** — one-click copy
- **Trust signals** — creator identity, review status, community ratings (V2 trust layer)
- **Per-creator profiles** — bio, list of Flows, domain depth

The distribution rail stays **git**. The plugin format stays the same. Only the discovery layer scales.

## Why not npm

We considered npm distribution (`npm i @flowy/cold-email-flow`). Decided against it:

- Claude Code's plugin system already does what we need
- npm adds infrastructure (CLI, package registry, version handling) without solving a real problem
- Git repos work fine for distribution; npm is overkill at any scale

The plugin system + per-creator git repos is the entire distribution architecture, today and at 1M Flows.

## What's locked vs what's still being figured out

**Locked:**
- V1 = one bundled plugin in this repo
- Post-V1 = per-creator plugin repos
- Discovery = flowy.sh
- Quality gate = creator review + community signals

**Still being figured out:**
- When to split: at what library size do we start moving Flows out of `flowy-flows` into their own repos? (Probably ~50, but TBD by usage)
- How to handle creator-paid Flows (V2 — needs Stripe Atlas)
- Verification badges (V2 — needs payment underneath)
- Cross-Flow dependencies (Flow A invokes Flow B?) — probably never

## Migration path

If you publish a Flow that becomes popular enough to deserve its own plugin repo:

1. Move `flows/<your-slug>/` from this repo to a new `<your-slug>` repo
2. Rename the directory from `flows/<your-slug>/` to `flow/` (singular) to match the per-creator plugin convention shown above.
3. Add `.claude-plugin/` to the new repo
4. Move the wrapper from `skills/<your-slug>/` in this repo to `skills/activate/` in the new repo
5. flowy.sh updates the install command on the listing page
6. The old bundled version stays in `flowy-flows` until users migrate (or we deprecate after a notice period)

No code changes needed — just file moves. The plugin system handles the rest.
