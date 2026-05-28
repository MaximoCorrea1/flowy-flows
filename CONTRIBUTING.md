# Contributing to flowy-flows

Thanks for wanting to add a Flow. This repo is the V1 home for hand-picked Flows that ship with the official `flowy` plugin.

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

Read the [Flow Folder Standard](https://github.com/MaximoCorrea1/flowy/blob/main/docs/standards/flow-folder-standard.md) for the full spec.

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

This repo bundles hand-picked Flows for V1. As the catalog grows, individual Flows will become their own plugin repos so users can install just what they want.

See [SCALING.md](./SCALING.md) for the path from V1 (one plugin) to scale (per-creator plugins).

## License

Flows in this repo are CC-BY-SA-4.0 by default. Contributors retain copyright; submitting a PR grants Flowy a non-exclusive license to display the Flow. Other open licenses (MIT, CC-BY-4.0, CC0-1.0) accepted if specified in the SKILL.md `license:` field.

## Questions

- General: https://flowy.dev
- This repo: open an issue or discussion
- Contact: maximocorrearosas@gmail.com
