// Override-injection scan for Flow content (FLOW.md + vendored SKILL.md).
//
// Best-effort, string-level — NOT a security perimeter. The authoritative gate is
// the server-side validator. This normalizes via NFKC (folds case + full-width and
// other compatibility variants) + whitespace collapse, then substring-matches a
// fixed pattern set.
//
// KNOWN GAP (documented, not silently assumed): cross-script homoglyphs — e.g. a
// Cyrillic 'о' (U+043E) standing in for Latin 'o' — are Unicode *confusables*, NOT
// NFKC compatibility equivalents, so NFKC does not fold them and this scan will not
// catch them. That is acceptable for a best-effort author-time check.
const PATTERNS = [
  "ignore claude.md",
  "disregard claude.md",
  "override claude.md",
  "supersede claude.md",
  "bypass claude.md",
  "claude.md is outdated",
  "claude.md does not apply",
  "treat claude.md as non-binding",
  "disregard project instructions",
  "override project instructions",
  "override project settings",
  "ignore project standards",
];

export function normalize(s) {
  return s.normalize("NFKC").toLowerCase().replace(/\s+/g, " ");
}

export function scanOverride(text) {
  const n = normalize(text);
  for (const p of PATTERNS) {
    if (n.includes(p)) return { hit: true, pattern: p };
  }
  return { hit: false, pattern: null };
}

export const OVERRIDE_PATTERNS = PATTERNS;
