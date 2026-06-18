#!/usr/bin/env node
// scaffold-flow: create a new Flow repo skeleton from templates/flow-standard.
//
// Usage: node tools/scaffold-flow.mjs <target-dir> <slug> "<title>"
//
// Copies the template tree, stamps __SLUG__/__TITLE__, and copies the validator
// tools (validate-flow.mjs + flow-scan.mjs) into <target-dir>/tests/ so the new
// repo self-validates with `bun test`.
//
// Build tooling, not shipped flow content — its output is verified end-to-end:
// the first scaffolded flow runs `bun test` (validateFlow) green in Phase 1.
import { cpSync, readdirSync, readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url)); // tools/
const repoRoot = join(here, "..");
const templateDir = join(repoRoot, "templates", "flow-standard");

// flow.test.ts is GENERATED into each repo (not shipped in the template) so the
// engine repo's own `bun test` never discovers a template test whose import can't resolve.
const FLOW_TEST = `import { test, expect } from "bun:test";
import { validateFlow } from "./validate-flow.mjs";
import { join } from "node:path";

test("this flow repo validates", () => {
  const r = validateFlow(join(import.meta.dir, ".."));
  if (!r.ok) console.error(r.errors.join("\\n"));
  expect(r.ok).toBe(true);
});
`;

const [, , targetDir, slug, title] = process.argv;
if (!targetDir || !slug || !title) {
  console.error('Usage: node tools/scaffold-flow.mjs <target-dir> <slug> "<title>"');
  process.exit(2);
}
if (!/^[a-z0-9][a-z0-9-]*$/.test(slug)) {
  console.error(`invalid slug: ${slug} (must be [a-z0-9-])`);
  process.exit(2);
}

cpSync(templateDir, targetDir, { recursive: true });

function stamp(dir) {
  for (const e of readdirSync(dir, { withFileTypes: true })) {
    const p = join(dir, e.name);
    if (e.isDirectory()) { stamp(p); continue; }
    const txt = readFileSync(p, "utf8");
    const out = txt.replaceAll("__SLUG__", slug).replaceAll("__TITLE__", title);
    if (out !== txt) writeFileSync(p, out);
  }
}
stamp(targetDir);

const testsDir = join(targetDir, "tests");
mkdirSync(testsDir, { recursive: true });
for (const f of ["validate-flow.mjs", "flow-scan.mjs"]) {
  cpSync(join(repoRoot, "tools", f), join(testsDir, f));
}
writeFileSync(join(testsDir, "flow.test.ts"), FLOW_TEST);

console.log(`scaffolded ${slug} at ${targetDir}`);
