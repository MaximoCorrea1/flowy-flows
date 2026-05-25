# Example: Building a feature with the routing table active

Shows the FLOW.md routing auto-invoking 5 different superpowers skills
in a single session. The user never types a skill name — the routing
table matches triggers and the agent reads the corresponding SKILL.md.

---

**User:** I need a download endpoint. Authenticated users hit
GET /listings/[slug]/download and get signed URLs. Rate-limited.

**Agent:** `Routing: writing-plans — clear task with known scope, needs breakdown`

*[Reads skills/writing-plans/SKILL.md, follows its instructions]*

Plan:
- [ ] Unit 1: Rate-limit migration
- [ ] Unit 2: Download helper (entitlement → rate-limit → sign → log)
- [ ] Unit 3: Route handler + page button

**User:** Go.

---

**Agent:** `Routing: executing-plans — plan approved, tasks are sequential`

*[Reads skills/executing-plans/SKILL.md]*

**Working on Unit 2:**

`Routing: test-driven-development — about to write implementation code`

*[Reads skills/test-driven-development/SKILL.md]*

```
Writing test: authed user → signed URL manifest.
Test fails: "downloadFlow not defined."
Implementing.
Test passes.

Writing test: anonymous → 401.
Test fails. Implementing. Passes.

Writing test: rate-limited → 429.
Test fails. Implementing. Passes.
```

`Routing: verification-before-completion — about to claim unit done`

*[Reads skills/verification-before-completion/SKILL.md]*

```
Running: bun test lib/listings/download.test.ts
Output: 4 pass, 0 fail
Evidence confirms: Unit 2 tests pass. ✓
```

Committed. ✅ Unit 2 done.

---

*[Units 1 + 3 complete via same routing...]*

---

**Agent:** `Routing: requesting-code-review — all units implemented`

*[Reads skills/requesting-code-review/SKILL.md]*

```
Review finding: P2 — rate-limit off-by-one (count > 5 permits 6).
Fix: count >= 5. Test updated. Passes.
```

`Routing: verification-before-completion — about to claim fixes done`

```
Running: bun test
Output: 5 pass, 0 fail ✓
```

---

**Agent:** `Routing: finishing-a-development-branch — all tasks done`

*[Reads skills/finishing-a-development-branch/SKILL.md]*

```
Tests: 5/5 pass ✓
1. Merge to main
2. Push + create PR
3. Keep branch
4. Discard
```

**User:** Option 2.

```
Pushed. PR created.
```

---

## What happened

**5 skills auto-invoked:** writing-plans, executing-plans, TDD (×3),
verification (×2), requesting-code-review, finishing-a-development-branch.

**User typed 0 skill names.** Every invocation was triggered by the
FLOW.md routing table.

**Without routing:** the agent writes all code in one shot without tests,
claims "done" without running the suite, pushes without review. The
rate-limit off-by-one ships to production undetected.
