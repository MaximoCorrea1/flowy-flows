/**
 * Tests for hooks/flowy-inject.sh — the deterministic enforcement core.
 *
 * CONTRACT UNDER TEST
 * -------------------
 * flowy-inject.sh is a Claude Code `UserPromptSubmit` hook. Claude Code pipes a
 * flat JSON object on stdin (`{ "session_id": "...", "prompt": "..." }`) and
 * exports two env vars: CLAUDE_PROJECT_DIR (project root) and
 * CLAUDE_PLUGIN_ROOT (this plugin's install dir).
 *
 * The hook reads per-session state from
 *   $CLAUDE_PROJECT_DIR/.flowy/state-<session_id>.json
 * and, if a Flow is active, injects a loud routing banner on stdout (which
 * Claude Code feeds back into the agent's context). It is FAIL-LOUD: it ALWAYS
 * exits 0 and degrades to a silent no-op on any error. It NEVER exits 2 / blocks.
 *
 * STATE FILE SHAPE (flowy-state-v1) — see hooks/flowy-inject.sh header.
 *   {
 *     "schema": "flowy-state-v1",
 *     "sessionId": "<id>",
 *     "activeFlows": [
 *       { "name": "superpowers-flow", "flowRef": "flows/superpowers-flow/FLOW.md" }
 *     ]
 *   }
 *
 * SHELL PINNING
 * -------------
 * Claude Code runs command hooks via Git Bash on this Windows machine, NOT WSL.
 * These tests spawn the script through the explicit Git Bash binary and assert
 * it resolves to Git Bash. If Git Bash is absent we SKIP loudly rather than
 * silently fall back to WSL (whose path semantics differ).
 */

import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { spawnSync } from "node:child_process";
import {
  existsSync,
  mkdirSync,
  mkdtempSync,
  rmSync,
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

// The script under test lives at ../hooks/flowy-inject.sh relative to this file.
const HERE = fileURLToPath(new URL(".", import.meta.url));
const SCRIPT = join(HERE, "..", "hooks", "flowy-inject.sh");

/**
 * Convert a Windows path to a Git-Bash-style path (/c/Users/...). Git Bash
 * accepts Windows paths in most contexts but exec-ing a script and quoting are
 * cleaner with a POSIX path. spawnSync passes argv directly so Git Bash's
 * msys path mangling does not apply to argv[1]; we hand it the Windows path and
 * let Git Bash open it. This works because Git Bash can open "C:\..." files.
 */
function runHook(opts: {
  projectDir: string;
  pluginRoot: string;
  stdin: string;
}): { code: number; stdout: string; stderr: string } {
  if (!GIT_BASH) {
    throw new Error("Git Bash not found — test should have been skipped");
  }
  const res = spawnSync(GIT_BASH, [SCRIPT], {
    input: opts.stdin,
    encoding: "utf8",
    env: {
      ...process.env,
      CLAUDE_PROJECT_DIR: opts.projectDir,
      CLAUDE_PLUGIN_ROOT: opts.pluginRoot,
    },
  });
  return {
    code: res.status ?? -1,
    stdout: res.stdout ?? "",
    stderr: res.stderr ?? "",
  };
}

// ---------------------------------------------------------------------------
// Per-test temp scaffolding. Paths deliberately contain a SPACE to exercise
// the script's quoting (mirrors the real "Projects VS" repo path).
// ---------------------------------------------------------------------------
let root: string;

function freshDirs(): { projectDir: string; pluginRoot: string } {
  const base = mkdtempSync(join(root, "case "));
  const projectDir = join(base, "project dir");
  const pluginRoot = join(base, "plugin root");
  mkdirSync(join(projectDir, ".flowy"), { recursive: true });
  mkdirSync(pluginRoot, { recursive: true });
  return { projectDir, pluginRoot };
}

function writeState(projectDir: string, sessionId: string, json: unknown) {
  writeFileSync(
    join(projectDir, ".flowy", `state-${sessionId}.json`),
    typeof json === "string" ? json : JSON.stringify(json, null, 2),
  );
}

/** Place a live FLOW.md under pluginRoot at the given relative ref. */
function writeFlowMd(pluginRoot: string, relPath: string) {
  const full = join(pluginRoot, relPath);
  mkdirSync(join(full, ".."), { recursive: true });
  writeFileSync(full, "# FLOW.md\nrouting tree here\n");
}

function stdinFor(sessionId: string | null, prompt = "do the thing"): string {
  const obj: Record<string, string> = { prompt };
  if (sessionId !== null) obj.session_id = sessionId;
  return JSON.stringify(obj);
}

beforeAll(() => {
  root = mkdtempSync(join(tmpdir(), "flowy-hook-"));
});

afterAll(() => {
  try {
    rmSync(root, { recursive: true, force: true });
  } catch {
    /* best-effort cleanup */
  }
});

// ---------------------------------------------------------------------------
// Sanity: the runner is pinned to Git Bash, not WSL.
// ---------------------------------------------------------------------------
describe("shell pinning", () => {
  test("resolves Git Bash, not WSL bash", () => {
    if (!HAVE_GIT_BASH) {
      // Loud skip — do NOT silently run under WSL.
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

const d = HAVE_GIT_BASH ? describe : describe.skip;

d("flowy-inject.sh", () => {
  // -------------------------------------------------------------------------
  // HAPPY PATH
  // -------------------------------------------------------------------------
  test("active flow whose flowRef resolves → banner + flow name, exit 0", () => {
    const { projectDir, pluginRoot } = freshDirs();
    writeFlowMd(pluginRoot, "flows/superpowers-flow/FLOW.md");
    writeState(projectDir, "A", {
      schema: "flowy-state-v1",
      sessionId: "A",
      activeFlows: [
        { name: "superpowers-flow", flowRef: "flows/superpowers-flow/FLOW.md" },
      ],
    });

    const r = runHook({ projectDir, pluginRoot, stdin: stdinFor("A") });

    expect(r.code).toBe(0);
    expect(r.stdout).toContain("Flowy routing ACTIVE");
    expect(r.stdout).toContain("superpowers-flow");
    expect(r.stdout).toContain("Routing:");
  });

  // -------------------------------------------------------------------------
  // NO-OP (the most important path: every normal repo with no Flow active)
  // -------------------------------------------------------------------------
  test("no state file at all → empty stdout, exit 0", () => {
    const { projectDir, pluginRoot } = freshDirs();
    const r = runHook({ projectDir, pluginRoot, stdin: stdinFor("A") });
    expect(r.code).toBe(0);
    expect(r.stdout.trim()).toBe("");
  });

  test("state with empty activeFlows → empty stdout, exit 0", () => {
    const { projectDir, pluginRoot } = freshDirs();
    writeState(projectDir, "A", {
      schema: "flowy-state-v1",
      sessionId: "A",
      activeFlows: [],
    });
    const r = runHook({ projectDir, pluginRoot, stdin: stdinFor("A") });
    expect(r.code).toBe(0);
    expect(r.stdout.trim()).toBe("");
  });

  // -------------------------------------------------------------------------
  // PENDING CLAIM
  // -------------------------------------------------------------------------
  test("state-PENDING.json + session_id=A → renamed to state-A.json, banner, exit 0", () => {
    const { projectDir, pluginRoot } = freshDirs();
    writeFlowMd(pluginRoot, "flows/superpowers-flow/FLOW.md");
    writeState(projectDir, "PENDING", {
      schema: "flowy-state-v1",
      sessionId: "PENDING",
      activeFlows: [
        { name: "superpowers-flow", flowRef: "flows/superpowers-flow/FLOW.md" },
      ],
    });

    const r = runHook({ projectDir, pluginRoot, stdin: stdinFor("A") });

    expect(r.code).toBe(0);
    expect(existsSync(join(projectDir, ".flowy", "state-A.json"))).toBe(true);
    expect(existsSync(join(projectDir, ".flowy", "state-PENDING.json"))).toBe(
      false,
    );
    expect(r.stdout).toContain("Flowy routing ACTIVE");
    expect(r.stdout).toContain("superpowers-flow");
  });

  // -------------------------------------------------------------------------
  // AUTO-REPAIR (stale flowRef → recompute flows/<name>/FLOW.md)
  // -------------------------------------------------------------------------
  test("stale flowRef but flows/<name>/FLOW.md exists → re-resolved, banner, exit 0", () => {
    const { projectDir, pluginRoot } = freshDirs();
    // The canonical location exists ...
    writeFlowMd(pluginRoot, "flows/coding-wisdom/FLOW.md");
    // ... but the state points at a stale cache-versioned path that does not.
    writeState(projectDir, "A", {
      schema: "flowy-state-v1",
      sessionId: "A",
      activeFlows: [
        {
          name: "coding-wisdom",
          flowRef: "flows/coding-wisdom@v0.1.0/FLOW.md",
        },
      ],
    });

    const r = runHook({ projectDir, pluginRoot, stdin: stdinFor("A") });

    expect(r.code).toBe(0);
    expect(r.stdout).toContain("Flowy routing ACTIVE");
    expect(r.stdout).toContain("coding-wisdom");
    expect(r.stdout).not.toContain("unreadable");
  });

  // -------------------------------------------------------------------------
  // CORRUPT (active in state, FLOW.md nowhere) → warning, still exit 0
  // -------------------------------------------------------------------------
  test("flow active but FLOW.md unresolvable → WARNING line, exit 0 (NOT 2)", () => {
    const { projectDir, pluginRoot } = freshDirs();
    // No FLOW.md written anywhere under pluginRoot.
    writeState(projectDir, "A", {
      schema: "flowy-state-v1",
      sessionId: "A",
      activeFlows: [
        { name: "ghost-flow", flowRef: "flows/ghost-flow/FLOW.md" },
      ],
    });

    const r = runHook({ projectDir, pluginRoot, stdin: stdinFor("A") });

    expect(r.code).toBe(0);
    expect(r.code).not.toBe(2);
    expect(r.stdout).toContain("Flowy:");
    expect(r.stdout).toContain("unreadable");
    expect(r.stdout).toContain("ghost-flow");
  });

  // -------------------------------------------------------------------------
  // SESSION ISOLATION
  // -------------------------------------------------------------------------
  test("two valid states A and B; session_id=A → names A's flow only, never B's", () => {
    const { projectDir, pluginRoot } = freshDirs();
    writeFlowMd(pluginRoot, "flows/superpowers-flow/FLOW.md");
    writeFlowMd(pluginRoot, "flows/solo-launch-playbook/FLOW.md");
    writeState(projectDir, "A", {
      schema: "flowy-state-v1",
      sessionId: "A",
      activeFlows: [
        { name: "superpowers-flow", flowRef: "flows/superpowers-flow/FLOW.md" },
      ],
    });
    writeState(projectDir, "B", {
      schema: "flowy-state-v1",
      sessionId: "B",
      activeFlows: [
        {
          name: "solo-launch-playbook",
          flowRef: "flows/solo-launch-playbook/FLOW.md",
        },
      ],
    });

    const r = runHook({ projectDir, pluginRoot, stdin: stdinFor("A") });

    expect(r.code).toBe(0);
    expect(r.stdout).toContain("superpowers-flow");
    expect(r.stdout).not.toContain("solo-launch-playbook");
    expect(r.stdout).not.toContain("state-B");
  });

  // -------------------------------------------------------------------------
  // PATH TRAVERSAL GUARD
  // -------------------------------------------------------------------------
  test("session_id '../../etc/x' → sanitized to no-op, exit 0, no stray output", () => {
    const { projectDir, pluginRoot } = freshDirs();
    // A real state file exists for a legit id; the traversal id must NOT reach it.
    writeFlowMd(pluginRoot, "flows/superpowers-flow/FLOW.md");
    writeState(projectDir, "A", {
      schema: "flowy-state-v1",
      sessionId: "A",
      activeFlows: [
        { name: "superpowers-flow", flowRef: "flows/superpowers-flow/FLOW.md" },
      ],
    });

    const r = runHook({
      projectDir,
      pluginRoot,
      stdin: stdinFor("../../etc/x"),
    });

    expect(r.code).toBe(0);
    expect(r.stdout.trim()).toBe("");
    // The legit A state must be untouched (no rename / deletion side-effect).
    expect(existsSync(join(projectDir, ".flowy", "state-A.json"))).toBe(true);
  });

  test("session_id with shell metacharacters → no-op, exit 0", () => {
    const { projectDir, pluginRoot } = freshDirs();
    const r = runHook({
      projectDir,
      pluginRoot,
      stdin: stdinFor('A"; rm -rf /; echo "'),
    });
    expect(r.code).toBe(0);
    expect(r.stdout.trim()).toBe("");
  });

  // -------------------------------------------------------------------------
  // MALFORMED / MISSING STDIN
  // -------------------------------------------------------------------------
  test("non-JSON stdin → no-op, exit 0", () => {
    const { projectDir, pluginRoot } = freshDirs();
    const r = runHook({ projectDir, pluginRoot, stdin: "this is not json" });
    expect(r.code).toBe(0);
    expect(r.stdout.trim()).toBe("");
  });

  test("empty stdin → no-op, exit 0", () => {
    const { projectDir, pluginRoot } = freshDirs();
    const r = runHook({ projectDir, pluginRoot, stdin: "" });
    expect(r.code).toBe(0);
    expect(r.stdout.trim()).toBe("");
  });

  test("stdin missing session_id field → no-op, exit 0", () => {
    const { projectDir, pluginRoot } = freshDirs();
    writeFlowMd(pluginRoot, "flows/superpowers-flow/FLOW.md");
    writeState(projectDir, "A", {
      schema: "flowy-state-v1",
      sessionId: "A",
      activeFlows: [
        { name: "superpowers-flow", flowRef: "flows/superpowers-flow/FLOW.md" },
      ],
    });
    const r = runHook({ projectDir, pluginRoot, stdin: stdinFor(null) });
    expect(r.code).toBe(0);
    expect(r.stdout.trim()).toBe("");
  });

  // -------------------------------------------------------------------------
  // NO-BLOCK INVARIANT — exit 0 across the board.
  // -------------------------------------------------------------------------
  test("no-block invariant: every scenario exits 0, never 2", () => {
    const { projectDir, pluginRoot } = freshDirs();
    writeFlowMd(pluginRoot, "flows/superpowers-flow/FLOW.md");

    const scenarios: string[] = [
      stdinFor("A"), // no state
      "", // empty
      "garbage", // malformed
      stdinFor("../../x"), // traversal
      stdinFor(null), // missing id
    ];

    for (const stdin of scenarios) {
      const r = runHook({ projectDir, pluginRoot, stdin });
      expect(r.code).toBe(0);
    }
  });

  // -------------------------------------------------------------------------
  // MULTIPLE ACTIVE FLOWS — comma-separated.
  // -------------------------------------------------------------------------
  test("two active flows both live → banner lists both names", () => {
    const { projectDir, pluginRoot } = freshDirs();
    writeFlowMd(pluginRoot, "flows/superpowers-flow/FLOW.md");
    writeFlowMd(pluginRoot, "flows/anthropic-toolkit/FLOW.md");
    writeState(projectDir, "A", {
      schema: "flowy-state-v1",
      sessionId: "A",
      activeFlows: [
        { name: "superpowers-flow", flowRef: "flows/superpowers-flow/FLOW.md" },
        {
          name: "anthropic-toolkit",
          flowRef: "flows/anthropic-toolkit/FLOW.md",
        },
      ],
    });

    const r = runHook({ projectDir, pluginRoot, stdin: stdinFor("A") });

    expect(r.code).toBe(0);
    expect(r.stdout).toContain("superpowers-flow");
    expect(r.stdout).toContain("anthropic-toolkit");
  });
});
