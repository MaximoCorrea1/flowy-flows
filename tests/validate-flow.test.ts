import { test, expect } from "bun:test";
import { validateFlow } from "../tools/validate-flow.mjs";
import { join } from "node:path";

const fx = (n) => join(import.meta.dir, "fixtures", n);

test("good fixture validates clean", () => {
  const r = validateFlow(fx("good-flow"));
  if (!r.ok) console.error(r.errors.join("\n"));
  expect(r.ok).toBe(true);
  expect(r.errors).toEqual([]);
});

test("bad fixture fails: dangling skill + missing attribution", () => {
  const r = validateFlow(fx("bad-flow"));
  expect(r.ok).toBe(false);
  expect(r.errors.some((e) => /routed skill .*missing-skill.* not found/.test(e))).toBe(true);
  expect(r.errors.some((e) => /missing ## Attribution/.test(e))).toBe(true);
});
