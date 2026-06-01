# flowy-flows

The hand-picked library of goal-bound **Flows** for [Flowy](https://flowy.dev), shipped as a Claude Code plugin.

> **Most AI agents have skills. None of them have a plan. Flowy Flows give the plan.**

A Flow is a set of hand-picked skills + a `FLOW.md` routing document that makes them mandatory. The agent reads the FLOW.md, follows its decision tree, and fires the right skill at the right moment.

## Install

```
/plugin marketplace add MaximoCorrea1/flowy-flows
/plugin install flowy@flowy-flows
```

All seed Flows become available as `flowy:<flow-name>` in your Skill tool.

## Verify your install

After installing, confirm you have the official plugin:

```
/plugin list
```

Look for:
```
flowy@flowy-flows  →  github.com/MaximoCorrea1/flowy-flows
```

If the source URL is anything other than `github.com/MaximoCorrea1/flowy-flows`, you do NOT have the official Flowy plugin. Uninstall and reinstall from the canonical URL:

```
/plugin uninstall flowy@<other>
/plugin marketplace add MaximoCorrea1/flowy-flows
/plugin install flowy@flowy-flows
```

**There is no central registry.** Any GitHub user can publish a plugin named `flowy`. The `github.com/MaximoCorrea1/flowy-flows` URL is the only canonical source for the official V1 plugin.

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

## Enforcement is built in

**Installing the plugin installs the hook — no setup, no `settings.json` editing.**

When a Flow is active, the hook injects a routing banner into the agent's context every turn, so routing survives context compaction. It is **fail-loud, not fail-closed**: the hook never blocks your prompts — when no Flow is active (or state is missing) it stays silent and gets out of your way.

To turn enforcement off, run `/flowy deactivate`.

> **One caveat:** Claude Code loads plugin hooks at session start, so a freshly installed plugin may need a restart to register its hook. If the routing banner doesn't appear right after your first install, restart Claude Code.

## Contributing

Read [CONTRIBUTING.md](./CONTRIBUTING.md) for the V1 submission paths (in-app upload at flowy.dev/me/flows/new OR GitHub PR to this repo).

## Scaling

See [SCALING.md](./SCALING.md) for how Flowy distribution scales from one bundled plugin (V1) to per-creator plugin repos (post-V1) to thousands of Flows.

## License

Flows are licensed under CC-BY-SA-4.0 by default. Contributors retain copyright; submitting a PR grants Flowy a non-exclusive license to display the Flow. Other open licenses (MIT, CC-BY-4.0, CC0-1.0) accepted if specified in the SKILL.md `license:` field.
