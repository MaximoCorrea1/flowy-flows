# flowy-flows

The hand-picked library of goal-bound **Flows** for [Flowy](https://flowy.dev), shipped as a Claude Code plugin.

A Flow is a set of hand-picked skills + a `FLOW.md` routing document that makes them mandatory. The agent reads the FLOW.md, follows its decision tree, and fires the right skill at the right moment.

## Install

```
/plugin marketplace add MaximoCorrea1/flowy-flows
/plugin install flowy@flowy-flows
```

All seed Flows become available as `flowy:<flow-name>` in your Skill tool.

## Use

```
flowy:superpowers-flow
```

Routing becomes mandatory for the session. Brainstorming fires before code. TDD fires before implementation. Verification fires before "done" claims.

### Bundled V1 seed Flows

| Flow | What it does |
|---|---|
| `flowy:superpowers-flow` | 14 superpowers skills with mandatory routing — TDD, debugging, code review, verification |
| `flowy:coding-wisdom` | 8 classic programming books distilled into agent-readable rules |
| `flowy:solo-launch-playbook` | 7-module marketing pipeline for solo founders |
| `flowy:anthropic-toolkit` | 13 official Anthropic skills with routing layer |

## Enforce routing across context compaction

Install the PreToolUse hook so routing persists even after the agent's context is compacted. See [flowy.dev/docs/hook](https://flowy.dev/docs/hook) or the hook section below.

## Contributing

Read [CONTRIBUTING.md](./CONTRIBUTING.md) for the V1 submission paths (in-app upload at flowy.dev/me/flows/new OR GitHub PR to this repo).

## Scaling

See [SCALING.md](./SCALING.md) for how Flowy distribution scales from one bundled plugin (V1) to per-creator plugin repos (post-V1) to thousands of Flows.

## License

Flows are licensed under CC-BY-SA-4.0 by default. Contributors retain copyright; submitting a PR grants Flowy a non-exclusive license to display the Flow. Other open licenses (MIT, CC-BY-4.0, CC0-1.0) accepted if specified in the SKILL.md `license:` field.
