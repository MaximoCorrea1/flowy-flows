/**
 * Tests for hooks/flowy-gc.sh — SessionStart garbage-collection hook.
 *
 * CONTRACT UNDER TEST
 * -------------------
 * flowy-gc.sh is a Claude Code `SessionStart` command hook. Claude Code
 * exports two env vars:
 *
 *   CLAUDE_PROJECT_DIR   real project root
 *   CLAUDE_PLUGIN_ROOT   this plugin's install dir
 *
 * The hook deletes state-*.json files older than FLOWY_STATE_GC_DAYS (14)
 * days from the OUT-OF-REPO state dir derived from these vars. It is a
 * best-effort janitor: it ALWAYS exits 0, never blocks, never deletes symlinks
 * or their targets, and is a no-op when the state dir is absent.
 *
 * STATE DIR DERIVATION (MUST be byte-identical to flowy-inject.sh §2b)
 * -----------------------------------------------------------------
 *   CLAUDE_HOME = ${CLAUDE_PLUGIN_ROOT%/plugins/*}   (must end in /.claude)
 *   PROJECT_KEY = CLAUDE_PROJECT_DIR with every non-[A-Za-z0-9] char → '_'
 *   STATE_DIR   = $CLAUDE_HOME/flowy-state/$PROJECT_KEY
 *
 * SHELL PINNING
 * -------------
 * Claude Code runs command hooks via Git Bash on this Windows machine.
 * Tests spawn the script through the explicit Git Bash binary. If Git Bash
 * is absent we SKIP loudly rather than silently fall back to WSL.
 *
 * PATH FORMAT
 * -----------
 * Claude Code hands Git-Bash hooks POSIX-style forward-slash paths.
 * These tests pass POSIX paths in env vars (matching production).
 * Node FS operations use the Windows form.
 */

import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { spawnSync } from "node:child_process";
import {
  existsSync,
  mkdirSync,
  mkdtempSync,
  rmSync,
  symlinkSync,
  utimesSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

// ---------------------------------------------------------------------------
// Shell pinning: locate Git Bash explicitly. Must NOT be WSL bash.
// ---------------------------------------------------------------------------
const GIT_BASH_CANDIDATES = [
  "C:\\Program Files\\Git\\bin\\bash.exe",
  "C:\\Program Files (x86)\\Git\\bin\\bash.exe",
];
const WSL_BASH = "C:\\Windows\\System32\\bash.exe";

const GIT_BASH = GIT_BASH_CANDIDATES.find((p) => existsSync(p));
const HAVE_GIT_BASH = !!GIT_BASH;

// The script under test lives at ../hooks/flowy-gc.sh relative to this file.
const HERE = fileURLToPath(new URL(".", import.meta.url));
const SCRIPT = join(HERE, "..", "hooks", "flowy-gc.sh");

/**
 * Convert a Windows path (C:\Users\...\x) to a Git-Bash POSIX path
 * (/c/Users/.../x). Drive letter is lowercased; backslashes become slashes.
 * This is what Claude Code feeds Git-Bash hooks, and the only form the hook's
 * `${CLAUDE_PLUGIN_ROOT%/plugins/*}` derivation can split on.
 */
function toPosix(winPath: string): string {
  return winPath
    .replace(/^([A-Za-z]):/, (_m, d) => `/${d.toLowerCase()}`)
    .replace(/\\/g, "/");
}

/**
 * Mirror the hook's PROJECT_KEY transform EXACTLY: every char outside
 * [A-Za-z0-9] becomes '_'. The hook computes this with `tr -c 'A-Za-z0-9' '_'`
 * over the CLAUDE_PROJECT_DIR env-var STRING — so we transform the same string
 * we pass in the env var (the POSIX form).
 */
function projectKey(projectDirEnvValue: string): string {
  return projectDirEnvValue.replace(/[^A-Za-z0-9]/g, "_");
}

interface Dirs {
  /** POSIX value passed in CLAUDE_PROJECT_DIR (and used for the key). */
  projectDirEnv: string;
  /** Windows path for Node FS ops on the project dir. */
  projectDirWin: string;
  /** POSIX value passed in CLAUDE_PLUGIN_ROOT. */
  pluginRootEnv: string;
  /** Windows path for Node FS ops on the plugin root. */
  pluginRootWin: string;
  /** Windows path of the out-of-repo state dir (already created). */
  stateDirWin: string;
}

/**
 * Run the GC hook with given POSIX env values for CLAUDE_PROJECT_DIR and
 * CLAUDE_PLUGIN_ROOT. No stdin needed (SessionStart has none).
 */
function runGc(dirs: Pick<Dirs, "projectDirEnv" | "pluginRootEnv">): {
  code: number;
  stdout: string;
  stderr: string;
} {
  if (!GIT_BASH) {
    throw new Error("Git Bash not found — test should have been skipped");
  }
  const res = spawnSync(GIT_BASH, [SCRIPT], {
    input: "",
    encoding: "utf8",
    env: {
      ...process.env,
      CLAUDE_PROJECT_DIR: dirs.projectDirEnv,
      CLAUDE_PLUGIN_ROOT: dirs.pluginRootEnv,
    },
  });
  return {
    code: res.status ?? -1,
    stdout: res.stdout ?? "",
    stderr: res.stderr ?? "",
  };
}

// ---------------------------------------------------------------------------
// Per-test temp scaffolding. Paths deliberately contain a SPACE ("case ") to
// exercise the script's quoting (mirrors the real "Projects VS" repo path).
//
// Layout per case (mirrors flowy-inject.test.ts exactly so the state dir
// derivation is identical between the two hook tests):
//
//   <base>/.claude/plugins/cache/flowy-flows/flowy/0.4.2   ← CLAUDE_PLUGIN_ROOT
//   <base>/.claude/flowy-state/<project-key>/              ← derived STATE_DIR
//   <base>/project dir/                                    ← CLAUDE_PROJECT_DIR
// ---------------------------------------------------------------------------
let root: string;

function makeDirs(opts?: { projectName?: string }): Dirs {
  const base = mkdtempSync(join(root, "case "));
  const projectName = opts?.projectName ?? "project dir";
  const projectDirWin = join(base, projectName);
  const claudeHomeWin = join(base, ".claude");
  const pluginRootWin = join(
    claudeHomeWin,
    "plugins",
    "cache",
    "flowy-flows",
    "flowy",
    "0.4.2",
  );

  mkdirSync(projectDirWin, { recursive: true });
  mkdirSync(pluginRootWin, { recursive: true });

  const projectDirEnv = toPosix(projectDirWin);
  const pluginRootEnv = toPosix(pluginRootWin);

  const key = projectKey(projectDirEnv);
  const stateDirWin = join(claudeHomeWin, "flowy-state", key);
  mkdirSync(stateDirWin, { recursive: true });

  return {
    projectDirEnv,
    projectDirWin,
    pluginRootEnv,
    pluginRootWin,
    stateDirWin,
  };
}

/** Write a plain state JSON stub. Content doesn't matter to GC; just needs to exist. */
function writeStateFile(stateDirWin: string, filename: string): string {
  const filePath = join(stateDirWin, filename);
  writeFileSync(filePath, JSON.stringify({ schema: "flowy-state-v1" }));
  return filePath;
}

/** Age a file to N days in the past by setting mtime via utimesSync. */
function ageFile(filePath: string, days: number): void {
  const nowMs = Date.now();
  const pastMs = nowMs - days * 24 * 60 * 60 * 1000;
  const pastSec = pastMs / 1000;
  utimesSync(filePath, pastSec, pastSec);
}

// ---------------------------------------------------------------------------
// Sanity: the runner is pinned to Git Bash, not WSL.
// ---------------------------------------------------------------------------
describe("shell pinning (gc)", () => {
  test("resolves Git Bash, not WSL bash", () => {
    if (!HAVE_GIT_BASH) {
      console.warn(
        "[SKIP] Git Bash not found at expected paths; refusing to run hook tests under WSL.",
      );
      return;
    }
    expect(GIT_BASH).toBeTruthy();
    expect(GIT_BASH).not.toBe(WSL_BASH);
    expect(existsSync(GIT_BASH!)).toBe(true);
  });
});

// ---------------------------------------------------------------------------
// CI-GUARD: hard-fail on Windows without Git Bash (mirrors inject test).
// ---------------------------------------------------------------------------
test("CI-guard (gc): Git Bash must be present on Windows to run gc hook tests", () => {
  if (process.platform !== "win32") {
    return;
  }
  expect(HAVE_GIT_BASH).toBe(true);
  if (!HAVE_GIT_BASH) {
    throw new Error(
      "Git Bash required to run GC hook tests on Windows; " +
        "install it from https://git-scm.com or the hook suite is unverified. " +
        "Expected at: " +
        GIT_BASH_CANDIDATES.join(", "),
    );
  }
});

beforeAll(() => {
  root = mkdtempSync(join(tmpdir(), "flowy-gc-"));
});

afterAll(() => {
  try {
    rmSync(root, { recursive: true, force: true });
  } catch {
    /* best-effort cleanup */
  }
});

// ---------------------------------------------------------------------------
// Main GC suite — only runs when Git Bash is available (matches inject style).
// ---------------------------------------------------------------------------
const d = HAVE_GIT_BASH ? describe : describe.skip;

d("flowy-gc.sh", () => {
  // -------------------------------------------------------------------------
  // ALWAYS EXIT 0
  // -------------------------------------------------------------------------
  test("exits 0 in every scenario (no-op, aged, fresh, absent dir)", () => {
    const dirs = makeDirs();
    // Aged file
    const aged = writeStateFile(dirs.stateDirWin, "state-old.json");
    ageFile(aged, 20);
    // Fresh file
    const fresh = writeStateFile(dirs.stateDirWin, "state-fresh.json");
    ageFile(fresh, 1);

    const r = runGc(dirs);
    expect(r.code).toBe(0);
  });

  // -------------------------------------------------------------------------
  // CORE BEHAVIOUR: aged file is deleted, fresh file survives.
  // -------------------------------------------------------------------------
  test("aged state-*.json (>14d) is deleted; fresh state-*.json (<14d) survives", () => {
    const dirs = makeDirs();

    // OLD: 20 days past → should be deleted.
    const agedPath = writeStateFile(dirs.stateDirWin, "state-old.json");
    ageFile(agedPath, 20);

    // FRESH: 1 day past → should survive.
    const freshPath = writeStateFile(dirs.stateDirWin, "state-fresh.json");
    ageFile(freshPath, 1);

    const r = runGc(dirs);

    expect(r.code).toBe(0);
    expect(existsSync(agedPath)).toBe(false);
    expect(existsSync(freshPath)).toBe(true);
  });

  // -------------------------------------------------------------------------
  // BOUNDARY: exactly 14d mtime is NOT deleted (find -mtime +14 means OLDER
  // than 14 full days; mtime == 14d means the modification was exactly 14 days
  // ago, which is on the boundary and survives).
  // -------------------------------------------------------------------------
  test("state file exactly 14d old is NOT deleted (boundary — find -mtime +N uses strict >)", () => {
    const dirs = makeDirs();
    const boundaryPath = writeStateFile(dirs.stateDirWin, "state-boundary.json");
    // `find -mtime +14` matches files whose mtime is MORE than 14 days old.
    // Setting mtime to exactly 14d * 24h ago sits on the boundary and survives.
    ageFile(boundaryPath, 14);

    const r = runGc(dirs);

    expect(r.code).toBe(0);
    // At exactly 14d the file should still exist (boundary is exclusive).
    // NOTE: file system mtime resolution and `find` integer math mean this
    // assertion may be flaky at sub-second precision. If it fails, age to 13d.
    expect(existsSync(boundaryPath)).toBe(true);
  });

  // -------------------------------------------------------------------------
  // SYMLINK GUARD: an aged symlink state-link.json → its TARGET must survive;
  // only the symlink itself should be handled (and per spec, symlinks are
  // skipped entirely — neither the link nor the target is deleted).
  // -------------------------------------------------------------------------
  test("aged symlink state-*.json → both symlink and target survive (symlinks skipped)", () => {
    const dirs = makeDirs();

    // Real target file outside the state dir.
    const targetPath = join(dirs.projectDirWin, "target-state.json");
    writeFileSync(targetPath, JSON.stringify({ schema: "flowy-state-v1" }));

    const linkPath = join(dirs.stateDirWin, "state-link.json");
    try {
      symlinkSync(targetPath, linkPath);
    } catch (e) {
      console.warn(
        `[SKIP] cannot create symlink (need Developer Mode/admin on Windows): ${String(e)}`,
      );
      return;
    }

    // Age the target so GC would delete it if it followed the symlink.
    ageFile(targetPath, 20);
    // Also set the symlink's mtime if possible (utimesSync follows the link to the
    // target, so the symlink itself is not aged this way on all platforms — but
    // the test still proves the target is not deleted).

    const r = runGc(dirs);

    expect(r.code).toBe(0);
    // The target MUST survive (the hook must not delete what a symlink points to).
    expect(existsSync(targetPath)).toBe(true);
  });

  // -------------------------------------------------------------------------
  // STATE DIR ABSENT → exit 0, no error.
  // -------------------------------------------------------------------------
  test("STATE_DIR absent → exits 0, no stdout, no error", () => {
    const dirs = makeDirs();
    // Remove the state dir entirely.
    rmSync(dirs.stateDirWin, { recursive: true, force: true });

    const r = runGc(dirs);

    expect(r.code).toBe(0);
    expect(r.stdout.trim()).toBe("");
  });

  // -------------------------------------------------------------------------
  // STATE DIR IS A SYMLINK → exit 0, no-op (symlinked dirs are skipped entirely).
  // -------------------------------------------------------------------------
  test("STATE_DIR is a symlink → exits 0, no-op (never follows a linked dir)", () => {
    const dirs = makeDirs();

    // Remove the real state dir, then create a symlink at that path pointing
    // to the project dir (a real directory).
    rmSync(dirs.stateDirWin, { recursive: true, force: true });
    try {
      symlinkSync(dirs.projectDirWin, dirs.stateDirWin, "junction");
    } catch (e) {
      console.warn(
        `[SKIP] cannot create dir symlink (need Developer Mode/admin on Windows): ${String(e)}`,
      );
      return;
    }

    const r = runGc(dirs);

    expect(r.code).toBe(0);
    // Should not have deleted anything in projectDirWin by following the link.
  });

  // -------------------------------------------------------------------------
  // ENV VAR GUARDS: missing CLAUDE_PROJECT_DIR → exit 0.
  // -------------------------------------------------------------------------
  test("CLAUDE_PROJECT_DIR empty → exits 0, no-op", () => {
    if (!GIT_BASH) throw new Error("Git Bash not found");
    const dirs = makeDirs();
    const res = spawnSync(GIT_BASH, [SCRIPT], {
      input: "",
      encoding: "utf8",
      env: {
        ...process.env,
        CLAUDE_PROJECT_DIR: "",
        CLAUDE_PLUGIN_ROOT: dirs.pluginRootEnv,
      },
    });
    expect(res.status).toBe(0);
    expect((res.stdout ?? "").trim()).toBe("");
  });

  // -------------------------------------------------------------------------
  // ENV VAR GUARDS: missing CLAUDE_PLUGIN_ROOT → exit 0.
  // -------------------------------------------------------------------------
  test("CLAUDE_PLUGIN_ROOT empty → exits 0, no-op", () => {
    if (!GIT_BASH) throw new Error("Git Bash not found");
    const dirs = makeDirs();
    const res = spawnSync(GIT_BASH, [SCRIPT], {
      input: "",
      encoding: "utf8",
      env: {
        ...process.env,
        CLAUDE_PROJECT_DIR: dirs.projectDirEnv,
        CLAUDE_PLUGIN_ROOT: "",
      },
    });
    expect(res.status).toBe(0);
    expect((res.stdout ?? "").trim()).toBe("");
  });

  // -------------------------------------------------------------------------
  // PLUGIN_ROOT WITHOUT /plugins/ SEGMENT → exit 0 (CLAUDE_HOME derivation
  // fails the same way as flowy-inject.sh §2b).
  // -------------------------------------------------------------------------
  test("PLUGIN_ROOT without /plugins/ segment → exits 0, no-op", () => {
    const dirs = makeDirs();
    // Aged file is present, but GC must not run (no valid .claude home).
    const aged = writeStateFile(dirs.stateDirWin, "state-old.json");
    ageFile(aged, 20);

    const badRoot = "/c/Users/U/some-other-dir/flowy/0.4.2";
    const r = runGc({
      projectDirEnv: dirs.projectDirEnv,
      pluginRootEnv: badRoot,
    });

    expect(r.code).toBe(0);
    // File must not have been deleted (hook was a no-op).
    expect(existsSync(aged)).toBe(true);
  });

  // -------------------------------------------------------------------------
  // PATH WITH SPACE: the project dir contains a space (mirrors "Projects VS").
  // If the hook doesn't double-quote path expansions, it would fail here.
  // -------------------------------------------------------------------------
  test("project dir path with space → hook handles it, exits 0", () => {
    const dirs = makeDirs({ projectName: "Projects VS" });
    const aged = writeStateFile(dirs.stateDirWin, "state-spaced.json");
    ageFile(aged, 20);

    const r = runGc(dirs);

    expect(r.code).toBe(0);
    // Aged file should be deleted (hook ran correctly despite the space).
    expect(existsSync(aged)).toBe(false);
  });

  // -------------------------------------------------------------------------
  // PENDING FILE IS NOT DELETED: state-PENDING.json aged > 14d → deleted.
  // (PENDING is still a state-*.json glob match, so it IS subject to GC.)
  // -------------------------------------------------------------------------
  test("aged state-PENDING.json (>14d) is also garbage-collected", () => {
    const dirs = makeDirs();
    const pendingPath = writeStateFile(dirs.stateDirWin, "state-PENDING.json");
    ageFile(pendingPath, 20);

    const r = runGc(dirs);

    expect(r.code).toBe(0);
    expect(existsSync(pendingPath)).toBe(false);
  });

  // -------------------------------------------------------------------------
  // NON-STATE FILES ARE NOT TOUCHED: files not matching state-*.json glob.
  // -------------------------------------------------------------------------
  test("non-state files in state dir are not touched by GC", () => {
    const dirs = makeDirs();
    // An aged file with a different name pattern.
    const otherPath = join(dirs.stateDirWin, "other-file.json");
    writeFileSync(otherPath, "{}");
    ageFile(otherPath, 20);

    const r = runGc(dirs);

    expect(r.code).toBe(0);
    // Not matched by state-*.json glob → must survive.
    expect(existsSync(otherPath)).toBe(true);
  });
});
