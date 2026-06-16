/**
 * Tests for hooks/flowy-paths.sh — the SINGLE SOURCE OF TRUTH for the
 * out-of-repo state dir. The hook, the GC, the activator, and the other test
 * oracle all derive STATE_DIR through this helper, so its canonical key MUST be
 * stable across every CLAUDE_PROJECT_DIR form Claude Code can hand us.
 *
 * THE BUG THIS GUARDS (Bug E): the hook receives Windows-form paths
 * (E:\... -> key E__...) while the activator computed an MSYS form
 * (/e/... -> key _e_...). Two keys, one project, banner never fires. The
 * helper canonicalizes EVERY form to the SAME key — and to MINIMIZE CHURN it
 * targets the Windows-form key the hook already produces in production, so
 * existing claimed state is not orphaned.
 *
 * Runs under Git Bash on Windows (the production platform). The helper is
 * sourced and flowy_state_dir invoked, mirroring how the activator/tests call
 * it: sh -c '. helper; flowy_state_dir "$pd" "$pr"'.
 */
import { describe, expect, test } from "bun:test";
import { spawnSync } from "node:child_process";
import { existsSync } from "node:fs";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

const GIT_BASH_CANDIDATES = [
  "C:\\Program Files\\Git\\bin\\bash.exe",
  "C:\\Program Files (x86)\\Git\\bin\\bash.exe",
];
const GIT_BASH = GIT_BASH_CANDIDATES.find((p) => existsSync(p));
const HAVE_GIT_BASH = !!GIT_BASH;

const HERE = fileURLToPath(new URL(".", import.meta.url));
const HELPER_WIN = join(HERE, "..", "hooks", "flowy-paths.sh");

/** Windows path -> Git-Bash POSIX (/c/...), so the helper can be sourced. */
function toPosix(p: string): string {
  return p.replace(/^([A-Za-z]):/, (_m, d) => `/${d.toLowerCase()}`).replace(/\\/g, "/");
}
const HELPER = toPosix(HELPER_WIN);

// A POSIX plugin root — the production form for CLAUDE_PLUGIN_ROOT (the hook's
// ${...%/plugins/*} only splits on this). claude-home -> /c/Users/U/.claude.
const PLUGIN_ROOT = "/c/Users/U/.claude/plugins/cache/flowy-flows/flowy/0.6.1";
const HOME_PREFIX = "/c/Users/U/.claude/flowy-state";

function stateDir(projectDir: string, pluginRoot: string = PLUGIN_ROOT): { code: number; out: string } {
  if (!GIT_BASH) throw new Error("Git Bash not found — test should have been skipped");
  const res = spawnSync(
    GIT_BASH,
    ["-c", '. "$1"; flowy_state_dir "$2" "$3"', "_", HELPER, projectDir, pluginRoot],
    { encoding: "utf8" },
  );
  return { code: res.status ?? -1, out: (res.stdout ?? "").trim() };
}

const d = HAVE_GIT_BASH ? describe : describe.skip;

d("flowy-paths.sh — canonical state dir", () => {
  test("Windows / mixed / MSYS / case forms of one project collapse to the live Windows-form key", () => {
    const expected = `${HOME_PREFIX}/E__Projects_VS_x`;
    expect(stateDir("E:\\Projects VS\\x").out).toBe(expected); // Windows (the hook's live form)
    expect(stateDir("E:/Projects VS/x").out).toBe(expected); // mixed separators
    expect(stateDir("e:\\Projects VS\\x").out).toBe(expected); // lowercase drive
    expect(stateDir("/e/Projects VS/x").out).toBe(expected); // MSYS (the activator's bug form)
  });

  test("trailing slash and repeated separators do not change the key", () => {
    const expected = `${HOME_PREFIX}/E__Projects_VS_x`;
    expect(stateDir("E:\\Projects VS\\x\\").out).toBe(expected);
    expect(stateDir("E:/Projects VS//x/").out).toBe(expected);
  });

  test("POSIX paths pass through byte-identical to today's transform (no churn for Linux/Mac)", () => {
    // First segment "home" is not a single letter -> not an MSYS drive -> unchanged.
    expect(stateDir("/home/u/My Repo").out).toBe(`${HOME_PREFIX}/_home_u_My_Repo`);
  });

  test("production shape: Windows project dir + POSIX plugin root -> Windows-form key (the real mismatch)", () => {
    expect(stateDir("E:\\Projects VS\\dumb alert plugin").out).toBe(
      `${HOME_PREFIX}/E__Projects_VS_dumb_alert_plugin`,
    );
  });

  test("plugin root accepted whether it carries /plugins/ or is the claude-home itself", () => {
    const expected = `${HOME_PREFIX}/E__proj`;
    expect(stateDir("E:\\proj", PLUGIN_ROOT).out).toBe(expected);
    expect(stateDir("E:\\proj", "/c/Users/U/.claude").out).toBe(expected);
  });

  test("no-op (empty output) on bad inputs — fail-loud, never a wrong key", () => {
    expect(stateDir("E:\\proj", "/c/Users/U/not-a-home").out).toBe(""); // home not ending /.claude
    expect(stateDir("", PLUGIN_ROOT).out).toBe(""); // empty project dir
    expect(stateDir("E:\\proj", "").out).toBe(""); // empty plugin root
  });

  test("flowy_state_root returns <claude-home>/flowy-state (parent of all project dirs)", () => {
    function root(src: string): string {
      const res = spawnSync(GIT_BASH!, ["-c", '. "$1"; flowy_state_root "$2"', "_", HELPER, src], {
        encoding: "utf8",
      });
      return (res.stdout ?? "").trim();
    }
    expect(root(PLUGIN_ROOT)).toBe(HOME_PREFIX); // strips /plugins/... -> /c/Users/U/.claude/flowy-state
    expect(root("/c/Users/U/.claude")).toBe(HOME_PREFIX); // accepts the claude-home directly
    expect(root("/c/Users/U/not-a-home")).toBe(""); // no-op on a non-.claude home
  });

  test("UNC single-letter server does NOT collide with a same-letter Windows drive (F1)", () => {
    // \\s\share\proj is a NETWORK path; S:\share\proj is local drive S. Pre-fix the
    // MSYS arm collapsed //s -> drive S and merged their keys (cross-project bleed).
    const unc = stateDir("\\\\s\\share\\proj").out;
    const drive = stateDir("S:\\share\\proj").out;
    expect(drive).toBe(`${HOME_PREFIX}/S__share_proj`);
    expect(unc).not.toBe(drive);
  });

  test("Windows-form and POSIX-form plugin root yield the SAME state dir (F2: home canonicalized)", () => {
    const winRoot = "C:\\Users\\U\\.claude\\plugins\\cache\\flowy-flows\\flowy\\0.6.2";
    const posixRoot = "/c/Users/U/.claude/plugins/cache/flowy-flows/flowy/0.6.2";
    expect(stateDir("E:\\proj", winRoot).out).toBe(`${HOME_PREFIX}/E__proj`);
    expect(stateDir("E:\\proj", winRoot).out).toBe(stateDir("E:\\proj", posixRoot).out);
  });
});
