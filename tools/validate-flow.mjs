// validate-flow: deterministic structural validation for a Flow repo.
//
// Checks (returns { ok, errors[] } — does not throw on a bad flow):
//   1. FLOW.md exists and has ## Routing + ## Attribution sections.
//   2. Every `invoke <slug>` in FLOW.md resolves to skills/<slug>/, an engine
//      skill, or an explicit `<!-- external-skills: a, b -->` allow-comment.
//   3. Every skills/<slug>/ has a SKILL.md, is named in ATTRIBUTION.md, and is
//      override-injection clean (flow-scan).
//   4. FLOW.md itself is override-injection clean.
//   5. .claude-plugin/{plugin,marketplace}.json exist and are valid JSON;
//      plugin.json has name + version.
import { readFileSync, existsSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { scanOverride } from "./flow-scan.mjs";

// engine skills a FLOW.md may route to without vendoring (bootstrap + host)
const ENGINE_SKILLS = new Set(["using-superpowers"]);

export function validateFlow(dir) {
  const errors = [];
  const flowPath = join(dir, "FLOW.md");
  if (!existsSync(flowPath)) return { ok: false, errors: [`FLOW.md not found in ${dir}`] };
  const flow = readFileSync(flowPath, "utf8");

  if (!/^##\s+Routing/m.test(flow)) errors.push("FLOW.md missing ## Routing section");
  if (!/^##\s+Attribution/m.test(flow)) errors.push("FLOW.md missing ## Attribution section");

  // skills present on disk
  const skillsDir = join(dir, "skills");
  const present = existsSync(skillsDir)
    ? readdirSync(skillsDir, { withFileTypes: true }).filter((d) => d.isDirectory()).map((d) => d.name)
    : [];

  // explicit external-skill allow-list comments in FLOW.md
  const external = new Set(
    [...flow.matchAll(/<!--\s*external-skills:\s*([^>]+?)\s*-->/g)]
      .flatMap((m) => m[1].split(",").map((s) => s.trim()).filter(Boolean)),
  );

  // every `invoke <slug>` resolves to a vendored, engine, or allow-listed skill
  for (const m of flow.matchAll(/\binvoke\s+([a-z0-9][a-z0-9-]*)/g)) {
    const slug = m[1];
    if (!present.includes(slug) && !ENGINE_SKILLS.has(slug) && !external.has(slug)) {
      errors.push(`routed skill "${slug}" not found in skills/ (nor engine/external allow-list)`);
    }
  }

  // each vendored skill: SKILL.md present, recorded in ATTRIBUTION.md, scan-clean
  const attribution = existsSync(join(dir, "ATTRIBUTION.md"))
    ? readFileSync(join(dir, "ATTRIBUTION.md"), "utf8")
    : "";
  for (const slug of present) {
    const sp = join(skillsDir, slug, "SKILL.md");
    if (!existsSync(sp)) {
      errors.push(`skills/${slug}/SKILL.md missing`);
      continue;
    }
    if (!attribution.includes(slug)) errors.push(`skills/${slug} not recorded in ATTRIBUTION.md`);
    const scan = scanOverride(readFileSync(sp, "utf8"));
    if (scan.hit) errors.push(`override-injection in skills/${slug}/SKILL.md: "${scan.pattern}"`);
  }

  const flowScan = scanOverride(flow);
  if (flowScan.hit) errors.push(`override-injection in FLOW.md: "${flowScan.pattern}"`);

  // plugin manifests valid JSON with name + version
  for (const f of ["plugin.json", "marketplace.json"]) {
    const p = join(dir, ".claude-plugin", f);
    if (!existsSync(p)) {
      errors.push(`.claude-plugin/${f} missing`);
      continue;
    }
    try {
      const j = JSON.parse(readFileSync(p, "utf8"));
      if (f === "plugin.json" && (!j.name || !j.version)) errors.push("plugin.json needs name + version");
    } catch {
      errors.push(`.claude-plugin/${f} is not valid JSON`);
    }
  }

  return { ok: errors.length === 0, errors };
}
