# Contributing to flowy-flows

**Want to publish a Flow?** Start at **https://flowy.dev/create-a-flow**. It walks you through what a Flow is, why make one, how to clone the blueprint, and how to validate before submitting.

This file is the **file-level format reference** for git-native contributors who want to PR directly. If you've never made a Flow, the web guide is faster.

---

## What you build vs. what Flowy provides

You build **two** things: your **skills** (the `SKILL.md` files) and a **validated `FLOW.md`** router. Flowy provides the rest **free** — enforcement, per-session state, and surviving compaction. You never write a hook or edit `settings.json`. Build a good router + good skills; Flowy makes them mandatory.

---

## Quick start

1. Browse `flows/_blueprint/` for the canonical reference structure.
2. Validate your Flow at https://flowy.dev/create-a-flow/validate before submitting.
3. Submit via in-app upload at https://flowy.dev/me/flows/new OR open a PR to this repo.

---

## Blueprint version compatibility

The canonical starter Flow lives at `flows/_blueprint/` and is versioned via `flows/_blueprint/BLUEPRINT_VERSION`.

If you forked the blueprint at an earlier version, check the current version to see what changed:

```bash
cat flows/_blueprint/BLUEPRINT_VERSION  # current version
```

The format itself is backward compatible. Version bumps signal added optional fields, improved examples, or clarified guidance — never breaking changes to required fields.

---

## What a Flow is

A Flow is a directory under `flows/<slug>/` containing:

```
flows/<slug>/
├── FLOW.md                  # routing table — required
├── SKILL.md                 # overview + attribution — required
├── LICENSE                  # required (CC-BY-SA-4.0 default, or MIT/CC-BY-4.0/CC0-1.0)
├── skills/                  # bundled skills — required, at least one
│   └── <skill-name>/
│       └── SKILL.md
└── examples/                # optional usage examples
    └── example-session.md
```

The Flow folder format is documented inline below — see "What a Flow is" above.

## Submission paths (V1)

Two paths, single quality bar. Both land in the same review queue.

### Path 1: In-app upload (recommended)

1. Sign in at https://flowy.dev with magic-link or GitHub OAuth
2. Go to https://flowy.dev/me/flows/new
3. Upload your Flow bundle via the file upload tab OR paste a public GitHub repo URL in the import tab
4. The Flow lands as `status='draft'` in the review queue
5. Maximo reviews and approves

This is the polished path. GitHub OAuth pre-fills your creator profile.

### Path 2: GitHub PR (this repo)

For git-native contributors who prefer the pure-git workflow:

1. Fork this repo
2. Create your Flow at `flows/<your-slug>/`
3. Open a PR using the template
4. Maximo reviews and merges

Both paths go through the same review. PRs let you iterate publicly with feedback in the PR thread.

## What we look for in review

- **FLOW.md actually routes** — has a decision tree, not just prose
- **Skills are bundled, not referenced** — each `skills/<name>/SKILL.md` is complete on its own
- **The Flow solves one problem end-to-end** — not a grab bag of unrelated skills
- **Domain credibility** — the creator has actual experience with the problem
- **Quality bar held in public** — the PR thread + draft-listings queue are the audit log

## Namespace ownership

V1 uses one canonical plugin: `flowy@flowy-flows` at github.com/MaximoCorrea1/flowy-flows. This is the only official Flowy plugin.

Post-V1 will allow per-creator plugin repos. Each creator's plugin is identified by their GitHub username, e.g., `cold-email@CreatorX`. Plugin names are NOT centrally registered — Claude Code's plugin system uses the GitHub repo path as the unique identifier.

What this means for contributors:
- V1: submit Flows here (this repo) or via in-app upload at flowy.dev. Approved Flows ship inside the canonical `flowy` plugin.
- Post-V1: you can publish your own plugin repo. flowy.dev will list it on your creator profile and show the install command.

What this means for users:
- Always verify your install: `/plugin list` should show `flowy@flowy-flows` from `github.com/MaximoCorrea1/flowy-flows` (V1) or from a known creator's repo (post-V1).
- Anyone publishing a plugin named `flowy` from a non-canonical URL is impersonating the official plugin. Report it to flowy.dev.

## What gets rejected

- Flows that are thin re-skins of existing skills with no routing value
- FLOW.md files that are prose without a decision tree
- Skills that depend on services we can't verify (closed APIs, paid tools without disclosure)
- Anything that tries to override CLAUDE.md or escalate agent privileges

## After merge

Once merged here:

- Your Flow ships as part of the `flowy` plugin (`/plugin install flowy@flowy-flows`)
- It appears as `flowy:<your-slug>` in the Skill tool for everyone who installs the plugin
- It gets a listing on https://flowy.dev with your handle credited
- You retain copyright; you grant Flowy a non-exclusive license to display the Flow

## Scaling

This repo bundles hand-picked Flows for V1. As the library grows, individual Flows will become their own plugin repos so users can install just what they want.

See [SCALING.md](./SCALING.md) for the path from V1 (one plugin) to scale (per-creator plugins).

## License

Flows in this repo are CC-BY-SA-4.0 by default. Contributors retain copyright; submitting a PR grants Flowy a non-exclusive license to display the Flow. Other open licenses (MIT, CC-BY-4.0, CC0-1.0) accepted if specified in the SKILL.md `license:` field.

## Questions

- General: https://flowy.dev
- This repo: open an issue or discussion
- Contact: maximocorrearosas@gmail.com
