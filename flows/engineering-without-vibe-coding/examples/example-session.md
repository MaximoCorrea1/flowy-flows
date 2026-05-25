# Example: Building a download endpoint with the routing table active

Shows the FLOW.md routing in action across 4 skill invocations. The
agent states its routing decision at each step per the integration block.

---

**User:** I need a download endpoint. Authenticated users hit
GET /listings/[slug]/download and get signed URLs. Rate-limited.

**Agent:** `Routing: superpowers:writing-plans — clear task, needs breakdown`

*[writing-plans skill fires: reads the spec, breaks into 3 units with
test scenarios, presents plan with checkboxes]*

**Agent presents:**
- [ ] Unit 1: Rate-limit migration
- [ ] Unit 2: Download helper (entitlement → rate-limit → sign → log)
- [ ] Unit 3: Route handler + page CTA

**User:** Approved. Go.

---

**Agent:** `Routing: superpowers:executing-plans — plan approved, tasks are sequential`

**Working on Unit 2:**

`Routing: superpowers:test-driven-development — about to write implementation code`

*[TDD skill fires]*

```
Writing test: authenticated user → returns signed URL manifest.
Test fails: "downloadFlow is not defined."
Implementing downloadFlow.
Test passes.

Writing test: anonymous user → 401.
Test fails. Adding auth check. Test passes.

Writing test: rate-limited → 429.
Test fails. Adding rate-limit. Test passes.
```

`Routing: superpowers:verification-before-completion — about to claim unit done`

*[verification skill fires]*

```
Running: bun test lib/listings/download.test.ts
Output: 4 pass, 0 fail
Claim verified: Unit 2 tests pass.
```

Committing: "feat: download helper with entitlement + rate-limit"
- [x] Unit 2 ✅

---

*[Units 1 + 3 complete via same routing...]*

---

**Agent:** `Routing: superpowers:requesting-code-review — all units implemented`

*[review skill fires: two-stage review]*

```
Finding: P2 — rate-limit off-by-one (count > 5 permits 6 downloads)
Fix: changed to count >= 5. Test updated. Passes.
```

`Routing: superpowers:verification-before-completion — about to claim review fixes done`

```
Running: bun test
Output: 5 pass, 0 fail
Claim verified: all tests pass after review fix.
```

---

**Agent:** `Routing: superpowers:finishing-a-development-branch — all tasks done`

*[finishing skill fires]*

```
Tests: 5/5 pass ✓
Options:
1. Merge back to main
2. Push and create PR
3. Keep branch as-is
4. Discard
```

**User:** Option 2.

```
Pushed. PR created: "feat: download endpoint with rate-limiting"
```

---

**Skills invoked in this session:** 5 (writing-plans, executing-plans,
test-driven-development ×3, verification-before-completion ×2,
requesting-code-review, finishing-a-development-branch).

**Skills that fired automatically via routing:** all of them. The user
never typed a skill name. The routing table matched each trigger and
the agent invoked the skill without being asked.

**What would have happened WITHOUT the routing:** the agent would have
written all the code in one shot without tests, claimed "done" without
running the test suite, and pushed without review. The rate-limit
off-by-one would have shipped to production.
