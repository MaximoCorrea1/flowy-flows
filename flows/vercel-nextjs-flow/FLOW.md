# FLOW.md: Next.js Production Quality

> Take a Next.js UI task from first keystroke to a fast, accessible, deployed page, firing the right Vercel skill at each phase.

> Skills vendored from Vercel (MIT). See ATTRIBUTION.md. Routing by Flowy.

## Phases

1. **Build**. Entry: writing or refactoring React/Next.js UI. Gate: code follows the performance and composition rules (named rule files cited).
2. **Review**. Entry: a buildable UI surface exists. Gate: Web Interface Guidelines findings list produced (file:line) and addressed.
3. **Optimize**. Entry: about to call the work done. Gate: signals.json collected and a ranked, metric-backed recommendation report exists.
4. **Deploy**. Entry: optimize gate passed and a ship is requested. Gate: a live Vercel URL is returned.

## Routing

```
USER MESSAGE
│
├─ INTAKE: first read the task, classify intent, pick the phase below ──────────
│     │
│     ├─ new request mixes goals? -> split into build / review / optimize / deploy, route each
│     └─ unsure which phase? -> ask one clarifying question, do not guess
│
├─ BUILD: writing, generating, or refactoring React/Next.js code ───────────────
│     │
│     ├─ component / page / data-fetch / bundle / re-render work?
│     │     -> invoke react-best-practices
│     │        Gate: changed code cites the rule files it satisfies (e.g. async-parallel, bundle-barrel-imports).
│     └─ boolean-prop sprawl, compound components, or reusable API design?
│           -> invoke composition-patterns
│           Gate: components compose via children/context, not boolean modes (rule file named).
│
├─ REVIEW: a buildable UI surface exists, check design + accessibility ──────────
│     │
│     └─ audit UI, UX, or accessibility before shipping?
│           -> invoke web-design-guidelines
│           Gate: a file:line findings list against the Web Interface Guidelines, each item resolved or waived.
│
├─ DONE-CHECK: about to claim the UI is done / ready to ship ────────────────────
│     │
│     └─ verify performance + cost before declaring complete?
│           -> invoke vercel-optimize
│           Gate: signals.json exists and a ranked recommendation report (Core Web Vitals + cost) is produced.
│
├─ DEPLOY: optimize gate passed and a ship is requested ─────────────────────────
│     │
│     ├─ ship a preview or push live?
│     │     -> invoke deploy-to-vercel
│     │        Gate: a live Vercel URL is returned (preview by default, production only if asked).
│     └─ deploy needs token-based / non-interactive auth? -> note it, deploy-to-vercel still owns the ship. Gate: live URL returned.
│
├─ ADVISE-ONLY: user is asking a question, not requesting work ──────────────────
│     └─ answer from the relevant skill's rules; do not edit files. Gate: none (no artifact produced).
│
├─ SCOPE CHANGE: the brief changed mid-flow ─────────────────────────────────────
│     └─ re-enter the earliest affected phase; prior downstream gates are void until re-passed.
│
├─ BLOCKED: waiting on an external dependency (token, deploy access, review sign-off)
│     └─ park the task, record the resume trigger, surface the blocker; do not fake the gate.
│
├─ REVIEW-LOOP: review or optimize feedback came back ───────────────────────────
│     └─ re-verify the failing gate only, then re-run its skill; do not skip ahead.
│
└─ DEFAULT: nothing above fits ─────────────────────────────────────────────────
      └─ Routing: none. State why no branch matched and ask for the missing detail.
```

## Priority on collision

1. Blocked (a parked dependency wins over any forward motion).
2. Scope changed (re-enter the earliest affected phase before continuing).
3. Done-check (verify before any claim of complete or deploy).
4. Lifecycle order (build, then review, then optimize, then deploy).
5. Advisory (answer-only beats picking a work branch when the user only asked).
6. Default (no match).

## You are rationalizing if you think…

- "It is a small component, the perf rules are overkill." A render waterfall or a barrel import is a small component's most common bug. Invoke `react-best-practices` and name the rule.
- "The design looks fine, skip the a11y review." Looks-fine is not keyboard-navigable or contrast-checked. Run `web-design-guidelines` and produce the file:line list before shipping.
- "I will eyeball performance, no need to collect metrics." `vercel-optimize` is observability-first: without signals.json you are guessing, and guesses are what blew the bill. Collect first.
- "Just deploy to production to test it." Default is a preview deploy. Production only on explicit request; ship preview, get the URL, then verify.


## Additional skills (also available)

The full upstream set is vendored in this Flow. The routing above sequences
the core lifecycle; these additional skills are available and fire when their
trigger matches. See ATTRIBUTION.md for the complete list and license.

### general

- `react-native-skills`
- `react-view-transitions`: Guide for implementing smooth, native-feeling animations using React's View Transition API (`<ViewTransition>` component, `addTransitionType`, and CSS view transition pseudo-elements). Use this skill whenever the user wants to add page transitions, animate route changes, create shared element animations, animate enter/exit of components, animate list reorder, implement directional (forward/back) navigation animations, or integrate view transitions in Next.js. Also use when the user mentions view transitions, `startViewTransition`, `ViewTransition`, transition types, or asks about animating between UI states in React without third-party animation libraries.
- `vercel-cli-with-tokens`: Deploy and manage projects on Vercel using token-based authentication. Use when working with Vercel CLI using access tokens rather than interactive login, e.g. "deploy to vercel", "set up vercel", "add environment variables to vercel".
- `writing-guidelines`: Review docs/prose for Writing Guidelines compliance. Use when asked to "review my docs", "check writing style", "audit prose", "review docs voice and tone", or "check this page against the writing handbook".

## Attribution

- `react-best-practices` by **Vercel** (https://github.com/vercel-labs/agent-skills), MIT.
- `composition-patterns` by **Vercel** (https://github.com/vercel-labs/agent-skills), MIT.
- `web-design-guidelines` by **Vercel** (https://github.com/vercel-labs/agent-skills), MIT.
- `vercel-optimize` by **Vercel** (https://github.com/vercel-labs/agent-skills), MIT.
- `deploy-to-vercel` by **Vercel** (https://github.com/vercel-labs/agent-skills), MIT.
