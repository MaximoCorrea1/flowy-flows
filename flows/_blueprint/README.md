# _blueprint — Flowy Starter Flow

This is the format-canonical starter Flow. Fork it to create your own.

## First steps after cloning

1. **Copy this `_blueprint/` folder OUTSIDE the flowy-flows repo.** Do NOT customize it in-place — you'll trip the activator's "project-local override" warning.
2. **Rename the folder.** From `_blueprint` to your Flow's name (lowercase-with-hyphens). Examples: `cold-email-pipeline`, `stripe-atlas-flow`, `rails-migration-flow`.
3. **Rename the example skill.** From `skills/your-skill-here/` to your actual skill name. Otherwise your published Flow ships with a placeholder skill name (loud failure, fails review).
4. **Edit `FLOW.md`.** Replace the example routing with YOUR decision tree. Keep the structure — it's what the validator looks for.
5. **Edit each `skills/<name>/SKILL.md`.** Replace the placeholder content with your actual skill instructions.
6. **Bump `BLUEPRINT_VERSION` semantics:** delete this file from your Flow. It's only for tracking the blueprint's own version, not yours.

## Validate before submitting

Paste your `FLOW.md` at https://flowy.dev/create-a-flow/validate. The validator catches:

- FLOW.md is prose, not a decision tree (most common rejection reason)
- Skills referenced but not bundled
- LICENSE missing
- Override patterns ("ignore CLAUDE.md", "override project instructions" — auto-rejected)

## Submit

Two paths, both go through the same review:

- **In-app upload:** https://flowy.dev/me/flows/new (recommended for first-time creators)
- **GitHub PR:** open a PR to https://github.com/MaximoCorrea1/flowy-flows

Approved Flows ship in the next plugin release and appear on https://flowy.dev/listings.

## Constraints

- 10 files maximum in the bundle (use `skillIndex` in SKILL.md frontmatter for larger skill sets)
- 5MB maximum bundle size
- License must be CC-BY-SA-4.0, MIT, CC-BY-4.0, or CC0-1.0

## Questions

Open a discussion or issue at https://github.com/MaximoCorrea1/flowy-flows.
