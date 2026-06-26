# FLOW.md: Full SDLC

> Take a software change from a written spec to a tested, hardened, shipped release, firing the right engineering skill at each step.

> Skills vendored from Addy Osmani (MIT). See ATTRIBUTION.md. Routing by Flowy.

## Phases

1. **Spec**. Entry: a new feature, change, or unclear requirement with no spec yet. Gate: an approved spec naming scope, non-goals, and acceptance criteria.
2. **Build (test-first)**. Entry: the spec is approved and you are about to write or change behavior. Gate: a failing test that now passes (red to green) for each unit of behavior.
3. **Harden**. Entry: the change touches untrusted input, auth, secrets, storage, or an external integration. Gate: a threat-model note plus the matching controls landed in code.
4. **Debug**. Entry: a test fails, the build breaks, or behavior does not match the spec. Gate: a regression test that reproduces the bug and now passes.
5. **CI**. Entry: the change is implemented and you need it enforced on every push. Gate: a pipeline config that gates merge on tests, lint, type-check, and build.
6. **Launch**. Entry: the change is green in CI and you are deploying. Gate: a completed pre-launch checklist with monitoring and a written rollback plan.

## Routing

```
ROUTE
│
├─ INTAKE: a new request arrives
│   └─ classify the work against the phases below, then enter the lowest unmet phase
│      -> invoke spec-driven-development  (when no spec exists yet)
│      Gate: a one-line restatement of intent + the phase you are entering
│
├─ SPEC? requirement is new, vague, or spans multiple files, and no spec exists
│   └─ write the spec before any code
│      -> invoke spec-driven-development
│      Gate: approved spec file with scope, non-goals, and acceptance criteria
│
├─ BUILD? spec approved and you are about to add or change behavior
│   ├─ new logic or behavior to implement
│   │   -> invoke test-driven-development
│   │   Gate: a failing test that now passes for the new behavior
│   └─ modifying existing functionality
│       -> invoke test-driven-development
│       Gate: characterization test green before and after the change
│
├─ HARDEN? change handles untrusted input, auth, secrets, storage, or a third party
│   ├─ accepts user input, uploads, webhooks, or LLM output
│   │   -> invoke security-and-hardening
│   │   Gate: threat-model note + input-validation / authz controls landed
│   └─ stores or transmits sensitive data
│       -> invoke security-and-hardening
│       Gate: secret-handling + at-rest/in-transit controls landed
│
├─ DEBUG? a test fails, the build breaks, or behavior diverges from the spec
│   └─ root-cause it before changing more code
│       -> invoke debugging-and-error-recovery
│       Gate: a regression test that reproduces the bug and now passes
│
├─ CI? change is implemented and must be enforced on every push
│   └─ stand up or extend the quality-gate pipeline
│       -> invoke ci-cd-and-automation
│       Gate: pipeline config gating merge on tests + lint + types + build
│
├─ DONE-CHECK? you believe the change is ready to ship
│   └─ run the pre-launch checklist before claiming done
│      -> invoke shipping-and-launch
│      Gate: completed pre-launch checklist + monitoring + rollback plan
│
├─ REVIEW-LOOP? a gate failed or a checklist item is red, re-verify after the fix
│   └─ re-enter the phase that owns the failure, do not advance
│      -> invoke debugging-and-error-recovery  (failing test or broken build)
│      -> invoke security-and-hardening        (unmet hardening control)
│      Gate: the failed gate's artifact now exists and is green
│
├─ ADVISE-ONLY? user asks a question or wants an opinion, not a change
│   └─ answer from the relevant skill's guidance; do not edit files
│      Gate: a recommendation citing which phase/skill applies
│
├─ SCOPE CHANGE? requirements shifted mid-flow
│   └─ update the spec first, then re-route from the lowest unmet phase
│      -> invoke spec-driven-development
│      Gate: revised spec; note which prior work is now out of scope
│
├─ BLOCKED? missing access, decision, or dependency
│   └─ state the blocker and the exact unblock needed; do not fake progress
│      Gate: a written blocker note naming the owner of the unblock
│
└─ DEFAULT: no branch fits, none of the above is a clean match
    └─ ask one clarifying question, or enter SPEC to force the ambiguity into writing
       Gate: a restated request precise enough to pick a phase
```

## Priority on collision

1. Blocked
2. Scope changed
3. Done-check
4. Lifecycle order (Spec before Build before Harden before Debug before CI before Launch)
5. Advisory
6. Default

## You are rationalizing if you think…

- "This change is small, I will skip the spec." Small-but-ambiguous is exactly where a five-line spec stops you building the wrong thing. Write the acceptance criteria first.
- "I will add the test after the code works." Writing the test first is what proves the code; a test written after the fact mostly proves the code you already wrote. Red before green.
- "It is internal, so I can skip hardening." Internal endpoints take untrusted input too. If any input crosses a trust boundary, run the threat model.
- "CI is green, so it is safe to ship." CI proves it builds and tests pass, not that it is observable or reversible. Run the pre-launch checklist and write the rollback plan before deploy.


## Additional skills (also available)

The full upstream set is vendored in this Flow. The routing above sequences
the core lifecycle; these additional skills are available and fire when their
trigger matches. See ATTRIBUTION.md for the complete list and license.

### general

- `api-and-interface-design`: Guides stable API and interface design. Use when designing APIs, module boundaries, or any public interface. Use when creating REST or GraphQL endpoints, defining type contracts between modules, or establishing boundaries between frontend and backend.
- `browser-testing-with-devtools`: Tests in real browsers via Chrome DevTools MCP. Use when building or debugging anything that runs in a browser. Use when you need to inspect the DOM, capture console errors, analyze network requests, profile performance, or verify visual output with real runtime data. Requires the chrome-devtools MCP server to be configured.
- `code-review-and-quality`: Conducts multi-axis code review. Use before merging any change. Use when reviewing code written by yourself, another agent, or a human. Use when you need to assess code quality across multiple dimensions before it enters the main branch.
- `code-simplification`: Simplifies code for clarity. Use when refactoring code for clarity without changing behavior. Use when code works but is harder to read, maintain, or extend than it should be. Use when reviewing code that has accumulated unnecessary complexity.
- `context-engineering`: Optimizes agent context setup. Use when starting a new session, when agent output quality degrades, when switching between tasks, or when you need to configure rules files and context for a project.
- `deprecation-and-migration`: Manages deprecation and migration. Use when removing old systems, APIs, or features. Use when migrating users from one implementation to another. Use when deciding whether to maintain or sunset existing code.
- `documentation-and-adrs`: Records decisions and documentation. Use when making architectural decisions, changing public APIs, shipping features, or when you need to record context that future engineers and agents will need to understand the codebase.
- `doubt-driven-development`: Subjects every non-trivial decision to a fresh-context adversarial review before it stands. Use when correctness matters more than speed, when working in unfamiliar code, when stakes are high (production, security-sensitive logic, irreversible operations), or any time a confident output would be cheaper to verify now than to debug later.
- `frontend-ui-engineering`: Builds production-quality UIs. Use when building or modifying user-facing interfaces. Use when creating components, implementing layouts, managing state, or when the output needs to look and feel production-quality rather than AI-generated.
- `git-workflow-and-versioning`: Structures git workflow practices. Use when making any code change. Use when committing, branching, resolving conflicts, or when you need to organize work across multiple parallel streams.
- `idea-refine`: Refines raw ideas into sharp, actionable concepts through structured divergent and convergent thinking. Use when an idea is still vague, when you need to stress-test assumptions before committing to a plan, or when you want to expand options before converging on one. Triggers on "ideate", "refine this idea", or "stress-test my plan".
- `incremental-implementation`: Delivers changes incrementally. Use when implementing any feature or change that touches more than one file. Use when you're about to write a large amount of code at once, or when a task feels too big to land in one step.
- `interview-me`: Extracts what the user actually wants instead of what they think they should want. Achieves this through one-question-at-a-time interview until ~95% confidence about the underlying intent. Use when an ask is underspecified ("build me X" without "for whom" or "why now"), when the user explicitly invokes ("interview me", "grill me", "are we sure?", "stress-test my thinking"), or when you catch yourself silently filling in ambiguous requirements before any plan, spec, or code exists.
- `observability-and-instrumentation`: Instruments code so production behavior is visible and diagnosable. Use when adding logging, metrics, tracing, or alerting. Use when shipping any feature that runs in production and you need evidence it works. Use when production issues are reported but you can't tell what happened from the available data.
- `performance-optimization`: Optimizes application performance. Use when performance requirements exist, when you suspect performance regressions, or when Core Web Vitals or load times need improvement. Use when profiling reveals bottlenecks that need fixing.
- `planning-and-task-breakdown`: Breaks work into ordered tasks. Use when you have a spec or clear requirements and need to break work into implementable tasks. Use when a task feels too large to start, when you need to estimate scope, or when parallel work is possible.
- `source-driven-development`: Grounds every implementation decision in official documentation. Use when you want authoritative, source-cited code free from outdated patterns. Use when building with any framework or library where correctness matters.
- `using-agent-skills`: Discovers and invokes agent skills. Use when starting a session or when you need to discover which skill applies to the current task. This is the meta-skill that governs how all other skills are discovered and invoked.

## Attribution

- `spec-driven-development` by **Addy Osmani** (https://github.com/addyosmani/agent-skills), MIT.
- `test-driven-development` by **Addy Osmani** (https://github.com/addyosmani/agent-skills), MIT.
- `security-and-hardening` by **Addy Osmani** (https://github.com/addyosmani/agent-skills), MIT.
- `debugging-and-error-recovery` by **Addy Osmani** (https://github.com/addyosmani/agent-skills), MIT.
- `ci-cd-and-automation` by **Addy Osmani** (https://github.com/addyosmani/agent-skills), MIT.
- `shipping-and-launch` by **Addy Osmani** (https://github.com/addyosmani/agent-skills), MIT.
