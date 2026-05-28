# flowy-flows

The hand-picked library of goal-bound **Flows** for [Flowy](https://flowy.dev), shipped as a Claude Code plugin.

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

## Enforce routing across context compaction

Install the PreToolUse hook so routing persists even after the agent's context is compacted.

### Setup

Add this to your `~/.claude/settings.json`:

**Unix/macOS:**
```json
"hooks": {
  "PreToolUse": [{
    "matcher": "",
    "hooks": [{
      "type": "command",
      "command": "cat \"$(pwd)/.flowy-state.json\" 2>/dev/null | python3 -c \"import json,sys; d=json.load(sys.stdin); print(json.dumps(d) if 'activeFlows' in d else '{}')\" 2>/dev/null || echo '{}'"
    }]
  }]
}
```

**Windows (PowerShell):**
```json
"hooks": {
  "PreToolUse": [{
    "matcher": "",
    "hooks": [{
      "type": "command",
      "command": "powershell -NoProfile -Command \"if (Test-Path (Join-Path $PWD '.flowy-state.json')) { $raw = Get-Content (Join-Path $PWD '.flowy-state.json') -Raw -Encoding UTF8; try { $parsed = $raw | ConvertFrom-Json; if ($parsed.activeFlows) { $raw } else { '{}' } } catch { '{}' } } else { '{}' }\""
    }]
  }]
}
```

The hook reads `.flowy-state.json` from your project root and injects the active Flow state into the agent's context on every tool call. If the state file is missing or malformed, it outputs `{}` (fail-closed).

## Contributing

Read [CONTRIBUTING.md](./CONTRIBUTING.md) for the V1 submission paths (in-app upload at flowy.dev/me/flows/new OR GitHub PR to this repo).

## Scaling

See [SCALING.md](./SCALING.md) for how Flowy distribution scales from one bundled plugin (V1) to per-creator plugin repos (post-V1) to thousands of Flows.

## License

Flows are licensed under CC-BY-SA-4.0 by default. Contributors retain copyright; submitting a PR grants Flowy a non-exclusive license to display the Flow. Other open licenses (MIT, CC-BY-4.0, CC0-1.0) accepted if specified in the SKILL.md `license:` field.
