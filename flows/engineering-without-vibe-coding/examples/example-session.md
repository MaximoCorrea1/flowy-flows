# Example: Adding a download endpoint to a web app

Redacted transcript showing Phases 3-6 of the Engineering Without Vibe
Coding flow on a real task. Phases 1-2 happened in a prior session;
the problem statement and spec already exist.

---

## Phase 3: Plan [MED]

**User:** I need a download endpoint for listings. Authenticated users
hit GET /listings/[slug]/download and get signed URLs to the bundle
files. Rate-limited to 5/day.

**Agent:**

Breaking into 3 units:

- [ ] **Unit 1: Rate-limit migration**
  - Files: `supabase/migrations/20260523_rate_limit.sql`
  - Approach: extend existing enum, reuse rate_limit_counters table
  - Test: migration applies cleanly
  - Verify: enum value exists in DB

- [ ] **Unit 2: Download helper (pure function)**
  - Files: `lib/listings/download.ts`, `lib/listings/download.test.ts`
  - Approach: entitlement check → rate-limit → sign URLs → log invocation
  - Test scenarios:
    - Happy: authed user, published listing → returns manifest
    - Edge: anonymous → 401
    - Edge: rate-limited → 429
    - Error: signing fails → 500
  - Verify: all tests green

- [ ] **Unit 3: Route handler + page CTA**
  - Files: `app/listings/[slug]/download/route.ts`, `app/listings/[slug]/page.tsx`
  - Approach: thin GET handler delegates to helper, page adds Download button
  - Verify: manual test — click button, get signed URLs

Does this look right?

**User:** Yes, go.

---

## Phase 4: Execute [CAVE]

**Agent:**

Writing test for Unit 2: happy path.
Test fails: "downloadFlow is not defined."
Implementing downloadFlow.
Test passes.

Writing test: anonymous user → 401.
Test fails: expected 401, got undefined.
Adding auth check.
Test passes.

Writing test: rate-limited → 429.
Test fails: expected 429.
Adding rate-limit check.
Test passes.

Writing test: signing fails → 500.
Test fails.
Adding error handling.
Test passes.

Committing: "feat(web): download helper with entitlement + rate-limit"

Writing route handler (Unit 3). No TDD — thin wrapper.
Adding Download button to listing page.
Manual check: button renders, links to /download.
Committing: "feat(web): download route handler + page CTA"

All units done. Tests green. No uncommitted changes.

---

## Phase 5: Review [MED]

**Agent:**

Reviewing diff (2 commits, 4 files changed):

| # | Severity | File | Issue |
|---|----------|------|-------|
| 1 | P2 | download.ts:43 | Rate-limit off-by-one: `count > 5` permits 6 downloads. Should be `count >= 5`. |
| 2 | P3 | download.ts:71 | Storage `.list()` is shallow — nested files excluded from manifest. |

No P0/P1. Fixing P2:

Changed `count > RATE_LIMIT` to `count >= RATE_LIMIT`.
Test updated. Passes.
Committing: "fix: rate-limit off-by-one in download endpoint"

P3 noted for follow-up (nested file support).

Gate passed: zero P0/P1.

---

## Phase 6: Ship [CAVE]

**Agent:**

Creating PR: "feat: download endpoint with rate-limiting"
Body: signed-URL manifest for published listings, 5/day rate limit,
auth-gated. 4 tests.
Pushing. Merged.

---

*Total: 3 phases, ~20 minutes, 4 tests, 3 commits. The rate-limit
off-by-one was caught in review — would have shipped to production
without Phase 5.*
