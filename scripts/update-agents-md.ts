#!/usr/bin/env bun

import { existsSync } from "node:fs";
import { readdir, readFile, writeFile } from "node:fs/promises";
import { join } from "node:path";

const SESSION_START = "<!-- SESSION_STATE_START -->";
const SESSION_END = "<!-- SESSION_STATE_END -->";
const ROADMAP_START = "<!-- ROADMAP_STATE_START -->";
const ROADMAP_END = "<!-- ROADMAP_STATE_END -->";

interface RoadmapState {
  updated_at: string;
  branch: string;
  head: string;
  completed: string[];
  in_progress: string | null;
  next_up: string[];
  blockers: string[];
  last_handoff: {
    at: string;
    reason: string;
    summary: string;
  } | null;
  recent_files: string[];
}

interface HookInput {
  hookEventName?: string;
  sessionId?: string;
  cwd?: string;
  workspaceRoot?: string;
  timestamp?: string;
  stopReason?: string;
}

interface CliArgs {
  completed: string[];
  next: string[];
  inProgress: string | null;
  blockers: string[];
  summary: string | null;
  reason: string | null;
  force: boolean;
}

interface ChangelogEntry {
  recorded_at: string;
  files: { path: string }[];
}

const ROADMAP_ITEMS = [
  "PR 1: build-logic + catalog + repo hygiene",
  "PR 2: Android Compose shell + minimal CI",
  "PR 3: libsignal-android packaging spike",
  "PR 4: core:common, core:model, core:designsystem, core:proto",
  "PR 5: server:relay skeleton (parallel track)",
  "PR 6: core:crypto — SessionManager + identity sealing",
  "PR 7: core:security — Keystore sealing",
  "PR 8: core:database — Room + SQLCipher (entities + DAOs)",
  "PR 9: core:domain — repository interfaces + use cases",
  "PR 10: core:database — repository implementations",
  "PR 11: core:network — Ktor client + WS + auth handshake",
  "PR 12: CI expansion — detekt, oxlint, emulator",
  "PR 13: feature:onboarding",
  "PR 14: feature:lock",
  "PR 15: feature:chat — conversation list UI",
  "PR 16: feature:settings — account drawer",
  "PR 17: feature:contacts",
  "PR 18: Conversation lifecycle — create/join/sync + membership API",
  "PR 19: feature:chat — thread + E2EE send/receive",
  "PR 20: Client ephemeral receipts + seen-by-all",
  "PR 21: Server purge + TTL cron + purge_notify broadcast",
  "PR 22: Group chat — per-member sender keys + membership rotation",
  "PR 23: Security hardening + release CI signing",
  "PR 24: Polish + observability + relay deploy docs",
] as const;

function parseArgs(argv: string[]): CliArgs {
  const args: CliArgs = {
    completed: [],
    next: [],
    inProgress: null,
    blockers: [],
    summary: null,
    reason: null,
    force: false,
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    const next = argv[i + 1];

    switch (arg) {
      case "--completed":
        if (next) {
          args.completed.push(next);
          i += 1;
        }
        break;
      case "--next":
        if (next) {
          args.next.push(next);
          i += 1;
        }
        break;
      case "--in-progress":
        if (next) {
          args.inProgress = next;
          i += 1;
        }
        break;
      case "--blocker":
        if (next) {
          args.blockers.push(next);
          i += 1;
        }
        break;
      case "--summary":
        if (next) {
          args.summary = next;
          i += 1;
        }
        break;
      case "--reason":
        if (next) {
          args.reason = next;
          i += 1;
        }
        break;
      case "--force":
        args.force = true;
        break;
      default:
        break;
    }
  }

  return args;
}

function defaultRoadmapState(branch: string, head: string): RoadmapState {
  return {
    updated_at: new Date().toISOString(),
    branch,
    head,
    completed: [],
    in_progress: "PR 1: build-logic + catalog + repo hygiene",
    next_up: [
      "PR 1: build-logic + catalog + repo hygiene",
      "PR 2: Android Compose shell + minimal CI",
    ],
    blockers: [],
    last_handoff: null,
    recent_files: [],
  };
}

function sortByPrNumber(items: string[]): string[] {
  return [...items].sort((left, right) => {
    const leftNumber = Number(prNumber(left) ?? 0);
    const rightNumber = Number(prNumber(right) ?? 0);
    return leftNumber - rightNumber;
  });
}

function inferNextUp(completed: string[]): string[] {
  const completedSet = new Set(completed.map((item) => item.split(":")[0]?.trim()));
  const pending = ROADMAP_ITEMS.filter((item) => {
    const pr = item.split(":")[0]?.trim();
    return pr && !completedSet.has(pr);
  });
  return pending.slice(0, 3);
}

function mergeRoadmapState(
  current: RoadmapState,
  args: CliArgs,
  branch: string,
  head: string,
  recentFiles: string[],
): RoadmapState {
  const completed = [...new Set([...current.completed, ...args.completed])];
  const blockers =
    args.blockers.length > 0
      ? [...new Set([...current.blockers, ...args.blockers])]
      : current.blockers;
  const nextUp = args.next.length > 0 ? args.next : inferNextUp(completed);
  const inProgress = args.inProgress ?? nextUp[0] ?? null;

  const lastHandoff =
    args.summary || args.reason || args.completed.length > 0
      ? {
          at: new Date().toISOString(),
          reason: args.reason ?? (args.completed.length > 0 ? "roadmap-phase" : "session-handoff"),
          summary:
            args.summary ??
            (args.completed.length > 0
              ? `Completed: ${args.completed.join(", ")}`
              : "Session continuity sync"),
        }
      : current.last_handoff;

  return {
    updated_at: new Date().toISOString(),
    branch,
    head,
    completed: sortByPrNumber(completed),
    in_progress: inProgress,
    next_up: nextUp,
    blockers,
    last_handoff: lastHandoff,
    recent_files: recentFiles.slice(0, 12),
  };
}

async function readRoadmapState(
  repoRoot: string,
  branch: string,
  head: string,
): Promise<RoadmapState> {
  const statePath = join(repoRoot, "ledgers", "roadmap-state.json");
  if (!existsSync(statePath)) {
    return defaultRoadmapState(branch, head);
  }

  const raw = await readFile(statePath, "utf8");
  return JSON.parse(raw) as RoadmapState;
}

async function writeRoadmapState(repoRoot: string, state: RoadmapState): Promise<void> {
  const ledgerDir = join(repoRoot, "ledgers");
  await Bun.$`mkdir -p ${ledgerDir}`.quiet();
  const statePath = join(ledgerDir, "roadmap-state.json");
  await writeFile(statePath, `${JSON.stringify(state, null, 2)}\n`);
}

function parsePorcelainPath(line: string): string | null {
  const trimmed = line.trim();
  if (!trimmed) {
    return null;
  }

  // Porcelain v1: XY<space>path (rename lines use "old -> new")
  const match = trimmed.match(/^.. (.+)$/);
  if (!match) {
    return null;
  }

  let path = match[1]!.trim();
  const renameArrow = path.lastIndexOf(" -> ");
  if (renameArrow !== -1) {
    path = path.slice(renameArrow + 4).trim();
  }
  if (path.startsWith('"') && path.endsWith('"')) {
    path = path.slice(1, -1);
  }

  return path;
}

async function recentChangedFiles(repoRoot: string): Promise<string[]> {
  const status = await Bun.$`git status --porcelain`.cwd(repoRoot).text();
  const files = status
    .split("\n")
    .map((line) => parsePorcelainPath(line))
    .filter((path): path is string => Boolean(path))
    .filter((path) => !path.startsWith("ledgers/changes/"));

  if (files.length > 0) {
    return [...new Set(files)];
  }

  const latest = await latestLedgerEntry(repoRoot);
  if (!latest) {
    return [];
  }

  return latest.files.map((file) => file.path);
}

async function latestLedgerEntry(repoRoot: string): Promise<ChangelogEntry | null> {
  const changesDir = join(repoRoot, "ledgers", "changes");
  if (!existsSync(changesDir)) {
    return null;
  }

  const entries = (await readdir(changesDir))
    .filter((name) => name.endsWith(".json"))
    .sort()
    .reverse();

  if (entries.length === 0) {
    return null;
  }

  const raw = await readFile(join(changesDir, entries[0]!), "utf8");
  return JSON.parse(raw) as ChangelogEntry;
}

function prNumber(item: string): string | null {
  const match = item.match(/^PR\s+(\d+)/);
  return match?.[1] ?? null;
}

function prTitle(item: string): string {
  const colon = item.indexOf(":");
  return colon === -1 ? item : item.slice(colon + 1).trim();
}

function prStatus(
  item: string,
  completedSet: Set<string>,
  inProgress: string | null,
): "done" | "in progress" | "pending" {
  const number = prNumber(item);
  if (number && completedSet.has(`PR ${number}`)) {
    return "done";
  }
  if (inProgress && prNumber(item) === prNumber(inProgress)) {
    return "in progress";
  }
  return "pending";
}

function renderRoadmapState(state: RoadmapState): string {
  const completedSet = new Set(
    state.completed
      .map((item) => item.split(":")[0]?.trim())
      .filter((pr): pr is string => Boolean(pr)),
  );
  const completedCount = ROADMAP_ITEMS.filter((item) => {
    const number = prNumber(item);
    return number && completedSet.has(`PR ${number}`);
  }).length;

  const nextUp = state.next_up.map((item) => `- ${item}`).join("\n");
  const blockers =
    state.blockers.length > 0 ? state.blockers.map((item) => `- ${item}`).join("\n") : "- _(none)_";

  const rows = ROADMAP_ITEMS.map((item) => {
    const number = prNumber(item) ?? "?";
    const title = prTitle(item);
    const status = prStatus(item, completedSet, state.in_progress);
    const label = status === "in progress" ? "**in progress**" : status;
    return `| ${number} | ${title} | ${label} |`;
  }).join("\n");

  return [
    `**Last updated:** ${state.updated_at}`,
    `**Branch:** \`${state.branch}\``,
    `**Progress:** ${completedCount} / ${ROADMAP_ITEMS.length} PRs complete`,
    "",
    "### In progress",
    state.in_progress ? `- ${state.in_progress}` : "- _(unset)_",
    "",
    "### Next up",
    nextUp,
    "",
    "### Blockers",
    blockers,
    "",
    "### PR status",
    "",
    "| PR | Title | Status |",
    "| --- | --- | --- |",
    rows,
    "",
    "_Auto-synced by `scripts/update-agents-md.ts`._",
  ].join("\n");
}

function renderSessionState(state: RoadmapState): string {
  const completed =
    state.completed.length > 0
      ? sortByPrNumber(state.completed)
          .map((item) => `- ${item}`)
          .join("\n")
      : "- _(none yet)_";

  const nextUp = state.next_up.map((item) => `- ${item}`).join("\n");

  const blockers =
    state.blockers.length > 0 ? state.blockers.map((item) => `- ${item}`).join("\n") : "- _(none)_";

  const recentFiles =
    state.recent_files.length > 0
      ? state.recent_files.map((item) => `- \`${item}\``).join("\n")
      : "- _(no local changes detected)_";

  const handoff = state.last_handoff
    ? `**${state.last_handoff.reason}** at ${state.last_handoff.at}\n\n${state.last_handoff.summary}`
    : "_No explicit handoff recorded yet._";

  return [
    `**Last updated:** ${state.updated_at}`,
    `**Branch:** \`${state.branch}\` @ \`${state.head.slice(0, 12)}\``,
    "",
    "### In progress",
    state.in_progress ? `- ${state.in_progress}` : "- _(unset)_",
    "",
    "### Completed",
    completed,
    "",
    "### Next up",
    nextUp,
    "",
    "### Blockers",
    blockers,
    "",
    "### Last handoff",
    handoff,
    "",
    "### Recently touched",
    recentFiles,
    "",
    "_Auto-synced by `scripts/update-agents-md.ts` (Grok Stop/SessionEnd hooks + `bun run agents:handoff`)._",
  ].join("\n");
}

function replaceMarkedBlock(
  markdown: string,
  startMarker: string,
  endMarker: string,
  block: string,
  label: string,
): string {
  const start = markdown.indexOf(startMarker);
  const end = markdown.indexOf(endMarker);

  if (start === -1 || end === -1 || end < start) {
    throw new Error(`${label} is missing ${startMarker} / ${endMarker} markers`);
  }

  const before = markdown.slice(0, start + startMarker.length);
  const after = markdown.slice(end);
  return `${before}\n\n${block}\n\n${after}`;
}

function replaceSessionBlock(agentsMd: string, sessionBlock: string): string {
  return replaceMarkedBlock(agentsMd, SESSION_START, SESSION_END, sessionBlock, "AGENTS.md");
}

function replaceRoadmapBlock(roadmapMd: string, roadmapBlock: string): string {
  return replaceMarkedBlock(roadmapMd, ROADMAP_START, ROADMAP_END, roadmapBlock, "ROADMAP.md");
}

async function readHookInput(): Promise<HookInput | null> {
  if (process.stdin.isTTY) {
    return null;
  }

  const text = await Bun.stdin.text();
  if (!text.trim()) {
    return null;
  }

  try {
    return JSON.parse(text) as HookInput;
  } catch {
    return null;
  }
}

async function main(): Promise<void> {
  const repoRoot = (await Bun.$`git rev-parse --show-toplevel`.text()).trim();
  const branch = (await Bun.$`git rev-parse --abbrev-ref HEAD`.cwd(repoRoot).text()).trim();
  const head = (await Bun.$`git rev-parse HEAD`.cwd(repoRoot).text()).trim();
  const args = parseArgs(process.argv.slice(2));
  const hookInput = await readHookInput();
  const recentFiles = await recentChangedFiles(repoRoot);

  const hasExplicitHandoff =
    args.completed.length > 0 ||
    args.next.length > 0 ||
    args.inProgress !== null ||
    args.summary !== null ||
    args.reason !== null ||
    args.blockers.length > 0;

  if (!args.force && !hasExplicitHandoff && recentFiles.length === 0) {
    return;
  }

  const current = await readRoadmapState(repoRoot, branch, head);
  const state = mergeRoadmapState(current, args, branch, head, recentFiles);

  if (hookInput?.hookEventName) {
    state.last_handoff = {
      at: hookInput.timestamp ?? new Date().toISOString(),
      reason: hookInput.hookEventName,
      summary:
        args.summary ??
        `Hook-triggered sync (${hookInput.hookEventName}${hookInput.stopReason ? `, ${hookInput.stopReason}` : ""})`,
    };
  }

  const statePath = join(repoRoot, "ledgers", "roadmap-state.json");
  const agentsPath = join(repoRoot, "AGENTS.md");
  const roadmapPath = join(repoRoot, "ROADMAP.md");

  const previousStateRaw = existsSync(statePath) ? await readFile(statePath, "utf8") : null;
  const nextStateRaw = `${JSON.stringify(state, null, 2)}\n`;
  const stateChanged = previousStateRaw !== nextStateRaw;

  const previousAgents = await readFile(agentsPath, "utf8");
  const nextAgents = replaceSessionBlock(previousAgents, renderSessionState(state));
  const agentsChanged = previousAgents !== nextAgents;

  let roadmapChanged = false;
  let nextRoadmap: string | null = null;
  if (existsSync(roadmapPath)) {
    const previousRoadmap = await readFile(roadmapPath, "utf8");
    nextRoadmap = replaceRoadmapBlock(previousRoadmap, renderRoadmapState(state));
    roadmapChanged = previousRoadmap !== nextRoadmap;
  }

  if (!stateChanged && !agentsChanged && !roadmapChanged) {
    return;
  }

  if (stateChanged) {
    await writeRoadmapState(repoRoot, state);
  }

  if (agentsChanged) {
    await writeFile(agentsPath, nextAgents);
  }

  if (roadmapChanged && nextRoadmap) {
    await writeFile(roadmapPath, nextRoadmap);
  }

  const pathsToStage = [
    stateChanged ? statePath : null,
    agentsChanged ? agentsPath : null,
    roadmapChanged ? roadmapPath : null,
  ].filter((path): path is string => path !== null);

  if (pathsToStage.length === 0) {
    return;
  }

  const add = Bun.spawnSync(["git", "add", ...pathsToStage], { cwd: repoRoot });
  if (add.exitCode !== 0) {
    console.error(add.stderr.toString());
    process.exit(add.exitCode ?? 1);
  }
}

await main();
